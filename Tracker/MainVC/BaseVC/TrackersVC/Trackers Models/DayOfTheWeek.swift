//
//  DayOfTheWeek.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 13.08.2024.
//

import Foundation

enum DayOfTheWeek: String, Codable, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    func localized() -> String {
        switch self {
        case .monday:
            return LocalizationKey.monday.localized()
        case .tuesday:
            return LocalizationKey.tuesday.localized()
        case .wednesday:
            return LocalizationKey.wednesday.localized()
        case .thursday:
            return LocalizationKey.thursday.localized()
        case .friday:
            return LocalizationKey.friday.localized()
        case .saturday:
            return LocalizationKey.saturday.localized()
        case .sunday:
            return LocalizationKey.sunday.localized()
        }
    }
}


