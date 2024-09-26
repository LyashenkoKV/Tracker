//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 10.09.2024.
//

import Foundation

final class StatisticsViewModel {
    private var statisticsStore: StatisticsStore
    var statistics: StatisticsData?
    
    init(statisticsStore: StatisticsStore) {
        self.statisticsStore = statisticsStore
    }
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    var hasStatistics: Bool {
        return statistics != nil
    }
    
    func updateStatisticsAfterAction(trackerStore: TrackerStore, recordStore: TrackerRecordStore) {
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
    }

    func fetchStatistics() {
        statisticsStore = StatisticsStore(persistentContainer: CoreDataStack.shared.persistentContainer)
        statistics = statisticsStore.fetchStatistics()
    }

    func getStatistic(for index: Int) -> (title: String, value: Int) {
        guard let statistics = statistics else { return ("N/A", 0) }
        
        switch index {
        case 0:
            return (LocalizationKey.bestPeriod.localized(), statistics.bestPeriod)
        case 1:
            return (LocalizationKey.idealDays.localized(), statistics.idealDays)
        case 2:
            return (LocalizationKey.completedTrackers.localized(), statistics.completedTrackers)
        case 3:
            return (LocalizationKey.averageValue.localized(), statistics.averageValue)
        default:
            return (LocalizationKey.notAvailable.localized(), 0)
        }
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
