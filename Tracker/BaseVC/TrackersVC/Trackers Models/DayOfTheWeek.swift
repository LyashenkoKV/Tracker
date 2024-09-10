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
            return NSLocalizedString("monday", comment: "Понедельник")
        case .tuesday:
            return NSLocalizedString("tuesday", comment: "Вторник")
        case .wednesday:
            return NSLocalizedString("wednesday", comment: "Среда")
        case .thursday:
            return NSLocalizedString("thursday", comment: "Четверг")
        case .friday:
            return NSLocalizedString("friday", comment: "Пятница")
        case .saturday:
            return NSLocalizedString("saturday", comment: "Суббота")
        case .sunday:
            return NSLocalizedString("sunday", comment: "Воскресенье")
        }
    }
}


