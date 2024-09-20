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
        
        switch filter {
        case .allTrackers:
            let weekdayIndex = calendar.component(.weekday, from: date)
            let adjustedIndex = (weekdayIndex + 5) % 7
            let selectedDayString = String(DayOfTheWeek.allCases[adjustedIndex].rawValue)
            return NSPredicate(format: "schedule CONTAINS[cd] %@", selectedDayString)
            
        case .today:
            let today = Date()
            let todayWeekdayIndex = calendar.component(.weekday, from: today)
            let todayAdjustedIndex = (todayWeekdayIndex + 5) % 7
            let todaySelectedDayString = String(DayOfTheWeek.allCases[todayAdjustedIndex].rawValue)
            
            Logger.shared.log(.info, message: "Проверка предиката: \(NSPredicate(format: "(schedule CONTAINS[cd] %@) OR (creationDate == %@)", todaySelectedDayString, today as NSDate))")

            return NSPredicate(format: "(schedule CONTAINS[cd] %@) OR (creationDate == %@)", todaySelectedDayString, today as NSDate)
        case .completed:
            return NSPredicate(format: "id IN %@", completedTrackerIds)
        case .uncompleted:
            return NSPredicate(format: "NOT (id IN %@)", completedTrackerIds)
        }
    }
}
