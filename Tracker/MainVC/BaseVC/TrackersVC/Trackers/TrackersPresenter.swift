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
    func filterTrackers(for date: Date, searchText: String?, filter: TrackerFilter)
    func loadTrackers()
    func loadCompletedTrackers()
    func deleteTracker(at indexPath: IndexPath)
    func togglePin(for tracker: Tracker)
    func updateTracker(_ updatedTracker: Tracker)
    func showContextMenu(for tracker: Tracker, at indexPath: IndexPath)
    func logEvent(event: String, screen: String, item: String?)
}

// MARK: - Object
final class TrackersPresenter: TrackersPresenterProtocol {
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let statisticsStore: StatisticsStore
    private let pinnedCategoryKey = "pinned_category_key"
    private let filterManager: TrackersFilterManager?
    
    weak var view: TrackersViewControllerProtocol?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    init(
        trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore,
        statisticsStore: StatisticsStore,
        filterManager: TrackersFilterManager?
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.statisticsStore = statisticsStore
        self.filterManager = filterManager
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
            
            updateStatisticsAfterAction()
            
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
            
            updateStatisticsAfterAction()
            
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
    
    func filterTrackers(for date: Date, searchText: String?, filter: TrackerFilter) {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        let adjustedIndex = (weekdayIndex + 5) % 7
        let selectedDayString = String(DayOfTheWeek.allCases[adjustedIndex].rawValue)

        let dateString = dateFormatter.string(from: date)
        let completedTrackerIds = recordStore.fetchCompletedTrackerIds(for: dateString)
        let predicate = filterManager?.createPredicate(
            for: date,
            filter: filter,
            completedTrackerIds: completedTrackerIds
        )
        
        trackerStore.fetchTrackers(predicate: predicate)
        let filteredTrackers = trackerStore.fetchTrackers()

        var finalFilteredTrackers = filteredTrackers.filter { trackerCoreData in
            let tracker = Tracker(from: trackerCoreData)

            if tracker.isRegularEvent {
                let matchesSchedule = tracker.schedule.contains(selectedDayString)
                if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                    let matchesSearch = tracker.name.lowercased().contains(searchText)
                    return matchesSchedule && matchesSearch
                } else {
                    return matchesSchedule
                }
            } else {
                guard let creationDate = tracker.creationDate else {
                    Logger.shared.log(
                        .error,
                        message: "Ошибка: у трекера \(tracker.name) нет creationDate."
                    )
                    return false
                }
                let isSameDay = calendar.isDate(creationDate, inSameDayAs: date)
                if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                    let matchesSearch = tracker.name.lowercased().contains(searchText)
                    return isSameDay && matchesSearch
                } else {
                    return isSameDay
                }
            }
        }
        
        finalFilteredTrackers.sort { $0.isPinned && !$1.isPinned }
        let categorizedTrackers = categorizeTrackers(finalFilteredTrackers)
  
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

            filterTrackers(for: view?.currentDate ?? Date(), searchText: nil, filter: .allTrackers)
        } catch {
            Logger.shared.log(
                .error,
                message: "Не удалось закрепить трекер: \(tracker.name)"
            )
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
                title: LocalizationKey.pinnedCategory.localized(),
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

            filterTrackers(for: view.currentDate, searchText: nil, filter: .allTrackers)
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при удалении трекера \(trackerToDelete.name)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func updateTracker(_ updatedTracker: Tracker) {
        do {
            try trackerStore.updateTracker(updatedTracker)
            loadTrackers()
        } catch {
            Logger.shared.log(.error, message: "Ошибка при обновлении трекера \(updatedTracker.name)")
        }
    }
    
    func showContextMenu(for tracker: Tracker, at indexPath: IndexPath) {
        guard let completedTrackers = view?.completedTrackers else { return }
        let contextMenuHelper = TrackersContextMenuHelper(
            tracker: tracker,
            indexPath: indexPath,
            presenter: self,
            viewController: TrackersViewController(),
            completedTrackers: completedTrackers
        )
        _ = contextMenuHelper.createContextMenu()
    }
}

// MARK: - Analytics
extension TrackersPresenter {

    func logEvent(event: String, screen: String, item: String? = nil) {
        var params: AnalyticsEventParam = [
            "event": event,
            "screen": screen
        ]
        if let item = item {
            params["item"] = item
        }
        AnalyticsService.report(event: event, params: params)
        
        Logger.shared.log(
            .debug,
            message: "Отправлено событие: \(event), screen: \(screen), item: \(item ?? "N/A")"
        )
    }
}

// MARK: - Statistics
extension TrackersPresenter {
    private func updateStatisticsAfterAction() {
        let allRecords = recordStore.fetchRecords()
        let allTrackers = trackerStore.fetchTrackers()
        
        let bestPeriod = calculateBestPeriod(records: allRecords)
        
        let idealDays = calculateIdealDays(records: allRecords, trackers: allTrackers)
        
        let completedTrackersCount = allRecords.count
        
        let averageValue = calculateAverageCompletion(records: allRecords)
        
        statisticsStore.saveStatistics(
            bestPeriod: bestPeriod,
            idealDays: idealDays,
            completedTrackers: completedTrackersCount,
            averageValue: averageValue
        )
        
        view?.reloadData()
    }
    
    private func calculateBestPeriod(records: [TrackerRecordCoreData]) -> Int {
        var bestPeriod = 0
        var currentPeriod = 0
        var previousDate: Date?

        let calendar = Calendar.current

        for record in records.sorted(by: { dateFormatter.date(from: $0.date ?? "") ?? Date() < dateFormatter.date(from: $1.date ?? "") ?? Date() }) {
            if let prevDate = previousDate, let currentDate = dateFormatter.date(from: record.date ?? "") {
                let daysBetween = calendar.dateComponents([.day], from: prevDate, to: currentDate).day ?? 0
                if daysBetween == 1 {
                    currentPeriod += 1
                } else {
                    bestPeriod = max(bestPeriod, currentPeriod)
                    currentPeriod = 1
                }
            } else {
                currentPeriod = 1
            }
            previousDate = dateFormatter.date(from: record.date ?? "")
        }

        return max(bestPeriod, currentPeriod)
    }
    
    private func calculateIdealDays(records: [TrackerRecordCoreData], trackers: [TrackerCoreData]) -> Int {
        let calendar = Calendar.current
 
        let groupedByDate = Dictionary(grouping: records, by: { calendar.startOfDay(for: dateFormatter.date(from: $0.date ?? "") ?? Date()) })
        
        var idealDays = 0

        for (_, recordsForDay) in groupedByDate {
            if recordsForDay.count == trackers.count {
                idealDays += 1
            }
        }

        return idealDays
    }
    
    private func calculateAverageCompletion(records: [TrackerRecordCoreData]) -> Int {
        let calendar = Calendar.current

        let groupedByDate = Dictionary(grouping: records, by: { calendar.startOfDay(for: dateFormatter.date(from: $0.date ?? "") ?? Date()) })
        
        let totalDays = groupedByDate.count
        let totalCompletedTrackers = groupedByDate.reduce(0) { $0 + $1.value.count }

        guard totalDays > 0 else { return 0 }
        return totalCompletedTrackers / totalDays
    }
}
