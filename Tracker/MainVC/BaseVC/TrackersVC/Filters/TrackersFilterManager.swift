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
        case .allTrackers, .today:
            let regularPredicate = NSPredicate(
                format: "isRegularEvent == YES AND schedule CONTAINS[cd] %@",
                selectedDayString
            )

            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let oneTimePredicate = NSPredicate(
                format: "isRegularEvent == NO AND creationDate >= %@ AND creationDate < %@",
                startOfDay as NSDate,
                endOfDay as NSDate
            )
            let finalPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [regularPredicate, oneTimePredicate]
            )

            return finalPredicate

        case .completed:
            return NSPredicate(format: "id IN %@", completedTrackerIds)
        case .uncompleted:
            return NSPredicate(format: "NOT (id IN %@)", completedTrackerIds)
        }
    }
}
