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
//
//final class TrackersFilterManager {
//    
//    var currentFilter: TrackerFilter = .allTrackers {
//        didSet {
//            onFilterChanged?(currentFilter)
//        }
//    }
//    
//    var onFilterChanged: ((TrackerFilter) -> Void)?
//    
//    func applyFilter(to trackers: [Tracker], for date: Date) -> [Tracker] {
//        switch currentFilter {
//        case .allTrackers:
//            return trackers
//        case .today:
//            let dayOfWeek = Calendar.current.component(.weekday, from: date)
//            return trackers.filter { $0.schedule.contains(String(dayOfWeek)) }
//        case .completed:
//            return trackers.filter { $0.isCompleted }
//        case .uncompleted:
//            return trackers.filter { !$0.isCompleted }
//        }
//    }
//}
