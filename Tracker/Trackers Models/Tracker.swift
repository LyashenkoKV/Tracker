//
//  Tracker.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import UIKit

// Триста раз пожалел, что не слелал на структурах(
enum Tracker: Codable {
    case tracker(
        id: UUID,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Schedule,
        categoryTitle: String,
        isRegularEvent: Bool
    )
    
    private enum TrackerType: String, Codable {
        case tracker
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, color, emoji, schedule, categoryTitle, isRegularEvent
        case type
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .tracker(let id, let name, let color, let emoji, let schedule, let categoryTitle, let isRegularEvent):
            try container.encode(TrackerType.tracker, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(color.toHexString(), forKey: .color)
            try container.encode(emoji, forKey: .emoji)
            try container.encode(schedule, forKey: .schedule)
            try container.encode(categoryTitle, forKey: .categoryTitle)
            try container.encode(isRegularEvent, forKey: .isRegularEvent)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TrackerType.self, forKey: .type)
        
        switch type {
        case .tracker:
            let id = try container.decode(UUID.self, forKey: .id)
            let name = try container.decode(String.self, forKey: .name)
            let colorHex = try container.decode(String.self, forKey: .color)
            let color = UIColor(hex: colorHex)
            let emoji = try container.decode(String.self, forKey: .emoji)
            let schedule = try container.decode(Schedule.self, forKey: .schedule)
            let categoryTitle = try container.decode(String.self, forKey: .categoryTitle)
            let isRegularEvent = try container.decodeIfPresent(Bool.self, forKey: .isRegularEvent) ?? true
            self = .tracker(
                id: id,
                name: name,
                color: color ?? UIColor(),
                emoji: emoji,
                schedule: schedule,
                categoryTitle: categoryTitle,
                isRegularEvent: isRegularEvent
            )
        }
    }
}
