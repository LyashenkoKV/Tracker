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
    func addTracker(_ tracker: Tracker, categotyTitle: String)
    func trackerCompletedMark(_ trackerId: UUID, date: String)
    func trackerCompletedUnmark(_ trackerId: UUID, date: String)
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool)
    func isDateValidForCompletion(date: Date) -> Bool
    func filterTrackers(for date: Date)
    func loadTrackers() 
}
// MARK: - Object
final class TrackersPresenter {
    weak var view: TrackersViewControllerProtocol?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    init(view: TrackersViewControllerProtocol) {
        self.view = view
    }
}

extension TrackersPresenter: TrackersPresenterProtocol {
    
    func addTracker(_ tracker: Tracker, categotyTitle: String) {
        var newCategories: [TrackerCategory] = []
        var categoryExists = false
        
        for category in view?.categories ?? [] {
            if case .category(let title, var trackers) = category, title == categotyTitle {
                trackers.append(tracker)
                newCategories.append(.category(title: title, trackers: trackers))
                categoryExists = true
            } else {
                newCategories.append(category)
            }
        }
        
        if !categoryExists {
            newCategories.append(.category(title: categotyTitle, trackers: [tracker]))
        }
        
        view?.categories = newCategories
        
        saveTrackers()
        
        DispatchQueue.main.async { [weak self] in
            self?.view?.reloadData()
            self?.view?.updatePlaceholderView()
        }
    }
    
    func trackerCompletedMark(_ trackerId: UUID, date: String) {
        guard let view = view else { return }
        if !isTrackerCompleted(trackerId, date: date) {
            view.completedTrackers.insert(.record(trackerId: trackerId, date: date))
            view.reloadData()
        }
    }
    
    func trackerCompletedUnmark(_ trackerId: UUID, date: String) {
        guard let view = view else { return }
        if let index = view.completedTrackers.firstIndex(where: {
            if case .record(let id, let recordDate) = $0 {
                return id == trackerId && recordDate == date
            }
            return false
        }) {
            view.completedTrackers.remove(at: index)
            view.reloadData()
        }
    }
    
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool {
        guard let view = view else { return false }
        return view.completedTrackers.contains(where: {
            if case .record(let id, let recordDate) = $0 {
                return id == trackerId && recordDate == date
            }
            return false
        })
    }
    
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool) {
        var trackerId: UUID?

        if case let .tracker(id, _, _, _, _, _) = tracker {
            trackerId = id
        }
        
        guard let id = trackerId else { return }
        
        let currentDateString = dateFormatter.string(from: view?.currentDate ?? Date())
        
        if isCompleted {
            trackerCompletedUnmark(id, date: currentDateString)
        } else {
            trackerCompletedMark(id, date: currentDateString)
        }
        view?.reloadData()
    }
    
    func isDateValidForCompletion(date: Date) -> Bool {
        return date <= Date()
    }
    
    func filterTrackers(for date: Date) {
        let savedTrackers = UserDefaults.standard.loadTrackers()

        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        
        let adjustedIndex = (weekdayIndex + 5) % 7
        let selectedDay = DayOfTheWeek.allCases[adjustedIndex]

        let filteredTrackers = savedTrackers.filter { tracker in
            if case .tracker(_, _, _, _, let schedule, _) = tracker {
                return schedule.containsDay(selectedDay)
            }
            return false
        }

        view?.categories = categorizeTrackers(filteredTrackers)
        view?.reloadData()
    }
    
    private func categorizeTrackers(_ trackers: [Tracker]) -> [TrackerCategory] {
        // Явно указываем типы ключа и значений в словаре
        let groupedTrackers: [String: [Tracker]] = Dictionary(grouping: trackers, by: { (tracker: Tracker) -> String in
            if case .tracker(_, _, _, _, _, let categoryTitle) = tracker {
                return categoryTitle
            }
            return "Uncategorized" // Обработка случая, если категория отсутствует
        })

        // Преобразуем сгруппированные данные в массив TrackerCategory
        return groupedTrackers.map { (title: String, trackers: [Tracker]) in
            TrackerCategory.category(title: title, trackers: trackers)
        }
    }
    
    private func saveTrackers() {
        let allTrackers = view?.categories.flatMap { category -> [Tracker] in
            if case .category(_, let trackers) = category {
                return trackers
            }
            return []
        } ?? []
        UserDefaults.standard.saveTrackers(allTrackers)
    }
    
    func loadTrackers() {
        let loadedTrackers = UserDefaults.standard.loadTrackers()
        let categorizedTrackers = categorizeTrackers(loadedTrackers)
        view?.categories = categorizedTrackers
        view?.reloadData()
        view?.updatePlaceholderView()
    }
}
