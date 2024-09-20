//
//  TrackersFilterManager.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 19.09.2024.
//

import Foundation

enum TrackerFilter: Int {
    case allTrackers = 0
    case today
    case completed
    case uncompleted
}

final class TrackersFilterManager {
    
    func createPredicate(for date: Date, filter: TrackerFilter, completedTrackerIds: Set<UUID>) -> NSPredicate {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        let adjustedIndex = (weekdayIndex + 5) % 7
        let selectedDayString = String(DayOfTheWeek.allCases[adjustedIndex].rawValue)
        
        switch filter {
        case .allTrackers:
            return NSPredicate(format: "schedule CONTAINS[cd] %@", selectedDayString)
        case .today:
            let todayString = String(DayOfTheWeek.allCases[adjustedIndex].rawValue)
            return NSPredicate(format: "schedule CONTAINS[cd] %@", todayString)
        case .completed:
            return NSPredicate(format: "id IN %@", completedTrackerIds)
        case .uncompleted:
            return NSPredicate(format: "NOT (id IN %@)", completedTrackerIds)
        }
    }
}
