//
//  Schedule.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import Foundation


//struct Schedule {
//    let dates: [String]
//}

enum Schedule: Codable {
    case dayOfTheWeek([DayOfTheWeek])

    private enum CodingKeys: String, CodingKey {
        case days
        case type
    }

    private enum ScheduleType: String, Codable {
        case dayOfTheWeek
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .dayOfTheWeek(let days):
            try container.encode(ScheduleType.dayOfTheWeek, forKey: .type)
            try container.encode(days.map { $0.rawValue }, forKey: .days)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ScheduleType.self, forKey: .type)
        switch type {
        case .dayOfTheWeek:
            let dayStrings = try container.decode([String].self, forKey: .days)
            let days = dayStrings.compactMap { DayOfTheWeek(rawValue: $0) }
            self = .dayOfTheWeek(days)
        }
    }
}

extension Schedule {
    func containsDay(_ day: DayOfTheWeek) -> Bool {
        switch self {
        case .dayOfTheWeek(let days):
            return days.contains(day)
        }
    }
}
