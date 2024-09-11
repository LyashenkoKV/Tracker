//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 10.09.2024.
//

import Foundation

final class StatisticsViewModel {
    var statistics: StatisticsData? = nil
    
    var hasStatistics: Bool {
        return statistics != nil
    }
    
    func fetchStatistics() {
        statistics = StatisticsData(
            bestPeriod: 6,
            idealDays: 2,
            completedTrackers: 5,
            averageValue: 4
        )
    }
}
