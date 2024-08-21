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
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool, date: Date)
    func isDateValidForCompletion(date: Date) -> Bool
    func filterTrackers(for date: Date)
    func loadTrackers()
    func loadCompletedTrackers()
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
    
    init(
        view: TrackersViewControllerProtocol
    ) {
        self.view = view
    }
}

extension TrackersPresenter: TrackersPresenterProtocol {
    
    func addTracker(_ tracker: Tracker, categotyTitle: String) {
        guard let view else { return }
        var allTrackers = UserDefaults.standard.loadTrackers()
        var updatedCategories = view.categories

        if let sectionIndex = view.categories.firstIndex(where: { $0.title == categotyTitle }) {
            let category = view.categories[sectionIndex]

            if !category.trackers.contains(where: { $0.id == tracker.id }) {
                let updatedTrackers = category.trackers + [tracker]
                let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
                updatedCategories[sectionIndex] = updatedCategory
            }
        } else {
            let newCategory = TrackerCategory(title: categotyTitle, trackers: [tracker])
            updatedCategories.append(newCategory)
        }

        view.categories = updatedCategories
        view.reloadData()
        allTrackers.append(tracker)
        allTrackers = Array(Set(allTrackers))
        
        UserDefaults.standard.saveTrackers(allTrackers)
    }

    func trackerCompletedMark(_ trackerId: UUID, date: String) {
        guard let view = view else { return }
        if !isTrackerCompleted(trackerId, date: date) {
            let newRecord = TrackerRecord(trackerId: trackerId, date: date)
            var updatedCompletedTrackers = view.completedTrackers
            updatedCompletedTrackers.insert(newRecord)
            view.completedTrackers = updatedCompletedTrackers
            view.reloadData()
        }
    }
    
    func trackerCompletedUnmark(_ trackerId: UUID, date: String) {
        guard let view = view else { return }
        if let index = view.completedTrackers.firstIndex(where: { $0.trackerId == trackerId && $0.date == date }) {
            view.completedTrackers.remove(at: index)
            view.reloadData()
        }
    }
    
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool {
        guard let view else { return false }
        return view.completedTrackers.contains { $0.trackerId == trackerId && $0.date == date }
    }
    
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool, date: Date) {
        guard let view else { return }

        let currentDateString = dateFormatter.string(from: date)
        
        if isCompleted {
            trackerCompletedUnmark(tracker.id, date: currentDateString)
        } else {
            trackerCompletedMark(tracker.id, date: currentDateString)
        }
        
        saveCompletedTrackersToUserDefaults()
        view.reloadData()
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
            if tracker.isRegularEvent {
                return tracker.schedule.contains(selectedDay)
            } else {
                let creationDateString = dateFormatter.string(from: tracker.creationDate ?? Date())
                let selectedDateString = dateFormatter.string(from: date)
                return selectedDateString == creationDateString
            }
        }

        view?.categories = categorizeTrackers(filteredTrackers)
        view?.reloadData()
    }
    
    private func categorizeTrackers(_ trackers: [Tracker]) -> [TrackerCategory] {
        let uniqueTrackers = Array(Set(trackers.map { $0.id })) // тут я удаляю дубликаты по id
            .compactMap { id in trackers.first { $0.id == id } }

        let groupedTrackers: [String: [Tracker]] = Dictionary(grouping: uniqueTrackers, by: { $0.categoryTitle })

        return groupedTrackers.map { (title: String, trackers: [Tracker]) in
            TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    private func saveTrackers() {
        var allTrackers = UserDefaults.standard.loadTrackers()

        if let currentTrackers = view?.categories.flatMap({ $0.trackers }) {
            allTrackers += currentTrackers
        }
        allTrackers = Array(Set(allTrackers))
        UserDefaults.standard.saveTrackers(allTrackers)
    }
    
    func saveCompletedTrackersToUserDefaults() {
        guard let view else { return }
        UserDefaults.standard.saveCompletedTrackers(view.completedTrackers)
    }
    
    func loadTrackers() {
        let loadedTrackers = UserDefaults.standard.loadTrackers()
        view?.categories = categorizeTrackers(loadedTrackers)
        view?.reloadData()
        view?.updatePlaceholderView()
    }
    
    func loadCompletedTrackers() {
        let loadedCompletedTrackers = UserDefaults.standard.loadCompletedTrackers()
        view?.completedTrackers = loadedCompletedTrackers
        view?.reloadData()
    }
}
