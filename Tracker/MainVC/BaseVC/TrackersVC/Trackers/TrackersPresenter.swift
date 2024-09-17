//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import Foundation

// MARK: - Protocol
protocol TrackersPresenterProtocol: AnyObject {
    var view: TrackersViewControllerProtocol? { get set }
    var dateFormatter: DateFormatter { get }
    func addTracker(_ tracker: Tracker, categoryTitle: String)
    func trackerCompletedMark(_ trackerId: UUID, date: String)
    func trackerCompletedUnmark(_ trackerId: UUID, date: String)
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool, date: Date)
    func isDateValidForCompletion(date: Date) -> Bool
    func filterTrackers(for date: Date, searchText: String?)
    func loadTrackers()
    func loadCompletedTrackers()
    func deleteTracker(at indexPath: IndexPath)
    func editTracker(at indexPath: IndexPath)
    func togglePin(for tracker: Tracker)
}

// MARK: - Object
final class TrackersPresenter: TrackersPresenterProtocol {
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let pinnedCategoryKey = "pinned_category_key"
    
    weak var view: TrackersViewControllerProtocol?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
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
    
    func filterTrackers(for date: Date, searchText: String? = nil) {
        let allTrackers = trackerStore.fetchTrackers()
        
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        let adjustedIndex = (weekdayIndex + 5) % 7
        let selectedDayString = String(DayOfTheWeek.allCases[adjustedIndex].rawValue)
        
        var filteredTrackers = allTrackers.filter { trackerCoreData in
            let tracker = Tracker(from: trackerCoreData)
            
            if tracker.isRegularEvent {
                let matchesSchedule = tracker.schedule.contains(selectedDayString)
                if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                    return matchesSchedule && (tracker.name.lowercased().contains(searchText))
                } else {
                    return matchesSchedule
                }
            } else {
                let isToday = calendar.isDate(tracker.creationDate ?? Date(), inSameDayAs: date)
                if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                    return isToday && (tracker.name.lowercased().contains(searchText))
                } else {
                    return isToday
                }
            }
        }
        
        filteredTrackers.sort { $0.isPinned && !$1.isPinned }
        
        let categorizedTrackers = categorizeTrackers(filteredTrackers)
        view?.categories = categorizedTrackers
        view?.visibleCategories = categorizedTrackers
        view?.reloadData()
    }
    
    func togglePin(for tracker: Tracker) {
        var updatedTracker = tracker
        updatedTracker.isPinned.toggle()

        do {
            if updatedTracker.isPinned {
                updatedTracker.originalCategoryTitle = tracker.categoryTitle
            }

            try trackerStore.updateTracker(updatedTracker)

            filterTrackers(for: view?.currentDate ?? Date(), searchText: nil)
        } catch {
            Logger.shared.log(.error, message: "Не удалось закрепить трекер: \(tracker.name)")
        }
    }
    
    func loadTrackers() {
        let loadedTrackers = trackerStore.fetchTrackers()
        let categorizedTrackers = categorizeTrackers(loadedTrackers)
        
        view?.categories = categorizedTrackers
        view?.visibleCategories = categorizedTrackers
        view?.reloadData()
    }

    func loadCompletedTrackers() {
        let loadedCompletedTrackers = recordStore.fetchRecords()
        let tempCompletedTrackers = Set(loadedCompletedTrackers.map { TrackerRecord(from: $0) })

        if tempCompletedTrackers != view?.completedTrackers {
            view?.completedTrackers = tempCompletedTrackers
        }
        view?.reloadData()
    }

    func categorizeTrackers(_ trackerCoreDataList: [TrackerCoreData]) -> [TrackerCategory] {
        var groupedTrackers: [String: [Tracker]] = Dictionary(
            grouping: trackerCoreDataList.map { Tracker(from: $0) },
            by: { $0.isPinned ? pinnedCategoryKey : $0.categoryTitle }
        )

        var categories: [TrackerCategory] = []
        if let pinnedTrackers = groupedTrackers.removeValue(forKey: pinnedCategoryKey) {
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString(
                    "pinned_category",
                    comment: "Закрепленные"
                ),
                trackers: pinnedTrackers
            )
            categories.append(pinnedCategory)
        }

        let sortedCategories = groupedTrackers.map { (title, trackers) in
            TrackerCategory(title: title, trackers: trackers)
        }

        categories.append(contentsOf: sortedCategories)

        return categories
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        guard let view else { return }
        
        let trackerToDelete = view.categories[indexPath.section].trackers[indexPath.row]
        
        do {
            try trackerStore.deleteTracker(withId: trackerToDelete.id)

            filterTrackers(for: view.currentDate, searchText: nil)
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
