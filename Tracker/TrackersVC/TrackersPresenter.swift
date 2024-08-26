//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import UIKit

// MARK: - Protocol
protocol TrackersPresenterProtocol {
    var view: TrackersViewControllerProtocol? { get set }
    var dateFormatter: DateFormatter { get }
    func addTracker(_ tracker: Tracker, categoryTitle: String)
    func trackerCompletedMark(_ trackerId: UUID, date: String)
    func trackerCompletedUnmark(_ trackerId: UUID, date: String)
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool, date: Date)
    func isDateValidForCompletion(date: Date) -> Bool
    func filterTrackers(for date: Date)
    func loadTrackers()
    func loadCompletedTrackers()
}

// MARK: - Object
final class TrackersPresenter: TrackersPresenterProtocol {
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    weak var view: TrackersViewControllerProtocol?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    init(trackerStore: TrackerStore, categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
    }
    
    func addTracker(_ tracker: Tracker, categoryTitle: String) {
        Logger.shared.log(.info, message: "Попытка добавления трекера: \(tracker.name) с категорией: \(categoryTitle)")
        do {
            try trackerStore.addTracker(tracker)
            Logger.shared.log(.info, message: "Трекер успешно добавлен: \(tracker.name)")
            loadTrackers()
        } catch {
            Logger.shared.log(.error, message: "Ошибка при добавлении трекера: \(tracker.name) - \(error.localizedDescription)")
        }
    }

    func trackerCompletedMark(_ trackerId: UUID, date: String) {
        do {
            let record = TrackerRecord(trackerId: trackerId, date: date)
            try recordStore.addRecord(record)
            loadCompletedTrackers()
        } catch {
            print("Failed to mark tracker as completed: \(error)")
        }
    }
    
    func trackerCompletedUnmark(_ trackerId: UUID, date: String) {
        do {
            try recordStore.removeRecord(for: trackerId, on: date)
            loadCompletedTrackers()
        } catch {
            print("Failed to unmark tracker as completed: \(error)")
        }
    }
    
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool {
        let records = recordStore.fetchRecords()
        return records.contains { $0.trackerId == trackerId && $0.date == date }
    }
    
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool, date: Date) {
        let currentDateString = dateFormatter.string(from: date)
        
        if isCompleted {
            trackerCompletedUnmark(tracker.id, date: currentDateString)
        } else {
            trackerCompletedMark(tracker.id, date: currentDateString)
        }
        
        view?.reloadData()
    }
    
    func isDateValidForCompletion(date: Date) -> Bool {
        return date <= Date()
    }
    
    func filterTrackers(for date: Date) {
        Logger.shared.log(.info, message: "Начало фильтрации трекеров по дате: \(dateFormatter.string(from: date))")
        
        let allTrackers = trackerStore.fetchTrackers()
        Logger.shared.log(.info, message: "Попытка загрузки трекеров из Core Data")
        Logger.shared.log(.info, message: "Трекеры успешно загружены из Core Data, всего загружено: \(allTrackers.count)")
        
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        let adjustedIndex = (weekdayIndex + 5) % 7
        let selectedDay = DayOfTheWeek.allCases[adjustedIndex]
        Logger.shared.log(.info, message: "Фильтрация трекеров по дню недели: \(selectedDay.rawValue)")
        
        let filteredTrackers = allTrackers.filter { trackerCoreData in
            let tracker = Tracker(from: trackerCoreData)
            
            // Логирование данных трекера перед фильтрацией
            Logger.shared.log(.info, message: """
                Трекер: \(tracker.name)
                Цвет: \(tracker.color)
                Эмодзи: \(tracker.emoji)
                Категория: \(tracker.categoryTitle)
                Регулярное событие: \(tracker.isRegularEvent)
                Расписание: \(tracker.schedule.map { $0.rawValue }.joined(separator: ", "))
                """)
            
            let containsDay = tracker.schedule.contains(selectedDay)
            Logger.shared.log(.info, message: "Трекер \(tracker.name) содержит день \(selectedDay.rawValue): \(containsDay)")
            
            return containsDay
        }
        
        Logger.shared.log(.info, message: "Трекеров после фильтрации: \(filteredTrackers.count)")
        
        view?.categories = categorizeTrackers(filteredTrackers)
        view?.reloadData()
    }
    
    func loadTrackers() {
        let loadedTrackers = trackerStore.fetchTrackers()
        view?.categories = categorizeTrackers(loadedTrackers)
        view?.reloadData()
    }
    
    func loadCompletedTrackers() {
        let loadedCompletedTrackers = recordStore.fetchRecords()
        view?.completedTrackers = Set(loadedCompletedTrackers.map { TrackerRecord(from: $0) })
        view?.reloadData()
    }

    private func categorizeTrackers(_ trackerCoreDataList: [TrackerCoreData]) -> [TrackerCategory] {
        let trackers = trackerCoreDataList.map { Tracker(from: $0) }
        let groupedTrackers: [String: [Tracker]] = Dictionary(grouping: trackers, by: { $0.categoryTitle })
        
        return groupedTrackers.map { (title, trackers) in
            TrackerCategory(title: title, trackers: trackers)
        }
    }
}
