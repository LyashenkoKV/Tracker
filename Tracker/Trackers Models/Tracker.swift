//
//  Tracker.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import UIKit

struct Tracker: Codable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Schedule
    let categoryTitle: String
    let isRegularEvent: Bool
    let creationDate: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id, 
             name,
             color,
             emoji,
             schedule,
             categoryTitle,
             isRegularEvent,
             creationDate
    }
    
    init(id: UUID,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Schedule,
        categoryTitle: String,
        isRegularEvent: Bool,
        creationDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.categoryTitle = categoryTitle
        self.isRegularEvent = isRegularEvent
        self.creationDate = creationDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color.toHexString(), forKey: .color)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(categoryTitle, forKey: .categoryTitle)
        try container.encode(isRegularEvent, forKey: .isRegularEvent)
        try container.encode(creationDate, forKey: .creationDate)  // Новое поле
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let colorHex = try container.decode(String.self, forKey: .color)
        color = UIColor(hex: colorHex) ?? UIColor()
        emoji = try container.decode(String.self, forKey: .emoji)
        schedule = try container.decode(Schedule.self, forKey: .schedule)
        categoryTitle = try container.decode(String.self, forKey: .categoryTitle)
        isRegularEvent = try container.decodeIfPresent(Bool.self, forKey: .isRegularEvent) ?? true
        creationDate = try container.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
    }
}
