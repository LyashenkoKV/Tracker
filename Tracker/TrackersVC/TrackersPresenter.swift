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
    func deleteTracker(at indexPath: IndexPath)
    func editTracker(at indexPath: IndexPath)
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
        do {
            let category = TrackerCategory(title: categoryTitle, trackers: [])
            try categoryStore.addCategory(category)
            try trackerStore.addTracker(tracker)
            loadTrackers()
            
        } catch {
            Logger.shared.log(
                .error, 
                message: "Ошибка при добавлении трекера: \(tracker.name)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func trackerCompletedMark(_ trackerId: UUID, date: String) {
        guard let view else { return }

        if isTrackerCompleted(trackerId, date: date) {
            return
        }
        
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        do {
            try recordStore.addRecord(newRecord)
            
            loadCompletedTrackers()
            view.reloadData()
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при добавлении записи для трекера \(trackerId) на дату \(date)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }

    func trackerCompletedUnmark(_ trackerId: UUID, date: String) {
        do {
            try recordStore.removeRecord(for: trackerId, on: date)

            self.loadCompletedTrackers()
            view?.reloadData()
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при удалении записи для трекера \(trackerId) на дату \(date)",
                metadata: ["❌": error.localizedDescription]
            )
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.view?.reloadData()
        }
    }
    
    func isDateValidForCompletion(date: Date) -> Bool {
        return date <= Date()
    }
    
    func filterTrackers(for date: Date) {
        let allTrackers = trackerStore.fetchTrackers()

        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        let adjustedIndex = (weekdayIndex + 5) % 7
        let selectedDay = DayOfTheWeek.allCases[adjustedIndex]
        
        let filteredTrackers = allTrackers.filter { trackerCoreData in
            let tracker = Tracker(from: trackerCoreData)

            if tracker.isRegularEvent {
                return tracker.schedule.contains(selectedDay)
            } else {
                return calendar.isDate(tracker.creationDate ?? Date(), inSameDayAs: date)
            }
        }

        let completedFilteredTrackers = filteredTrackers.filter { tracker in
            let isCompleted = view?.completedTrackers.contains {
                $0.trackerId == tracker.id && $0.date == dateFormatter.string(from: date)
            } ?? false

            return !isCompleted || tracker.isRegularEvent
        }

        view?.categories = categorizeTrackers(completedFilteredTrackers)
        view?.reloadData()
    }

    
    func loadTrackers() {
        let loadedTrackers = trackerStore.fetchTrackers()
        let categorizedTrackers = categorizeTrackers(loadedTrackers)
        view?.categories = categorizedTrackers
        
        DispatchQueue.main.async {
            self.view?.reloadData()
        }
    }

    func loadCompletedTrackers() {
        let loadedCompletedTrackers = recordStore.fetchRecords()
        let tempCompletedTrackers = Set(loadedCompletedTrackers.map { TrackerRecord(from: $0) })

        if tempCompletedTrackers != view?.completedTrackers {
            view?.completedTrackers = tempCompletedTrackers
        }
        view?.reloadData()
    }

    private func categorizeTrackers(_ trackerCoreDataList: [TrackerCoreData]) -> [TrackerCategory] {
        let trackers = trackerCoreDataList.map { trackerCoreData -> Tracker in
            let tracker = Tracker(from: trackerCoreData)
            return tracker
        }

        let groupedTrackers: [String: [Tracker]] = Dictionary(grouping: trackers, by: { $0.categoryTitle })

        groupedTrackers.forEach { (title, trackers) in
            Logger.shared.log(.info, message: "Категория: \(title), Количество трекеров: \(trackers.count)")
        }

        let trackerCategories = groupedTrackers.map { (title, trackers) -> TrackerCategory in
            return TrackerCategory(title: title, trackers: trackers)
        }
        return trackerCategories
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        guard let view = view else { return }
        
        let trackerToDelete = view.categories[indexPath.section].trackers[indexPath.row]
        
        do {
            try trackerStore.deleteTracker(withId: trackerToDelete.id)

            loadTrackers()
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при удалении трекера \(trackerToDelete.name)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func editTracker(at indexPath: IndexPath) {}
}
