//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import Foundation

//struct TrackerCategory {
//    let title: String
//    let trackers: [Tracker]
//}

enum TrackerCategory: Codable {
    case category(
        title: String,
        trackers: [Tracker]
    )

    private enum CodingKeys: String, CodingKey {
        case title, trackers
        case type
    }

    private enum CategoryType: String, Codable {
        case category
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .category(let title, let trackers):
            try container.encode(CategoryType.category, forKey: .type)
            try container.encode(title, forKey: .title)
            try container.encode(trackers, forKey: .trackers)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CategoryType.self, forKey: .type)
        
        switch type {
        case .category:
            let title = try container.decode(String.self, forKey: .title)
            let trackers = try container.decode([Tracker].self, forKey: .trackers)
            self = .category(title: title, trackers: trackers)
        }
    }
}
