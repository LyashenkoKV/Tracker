//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 10.09.2024.
//

import Foundation

final class StatisticsViewModel {
    private var statisticsStore: StatisticsStore!
    var statistics: StatisticsData?

    var hasStatistics: Bool {
        return statistics != nil
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
}
