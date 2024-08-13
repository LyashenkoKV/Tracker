//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import Foundation

//struct TrackerRecord {
//    let trackerId: UUID
//    let date: String
//}

enum TrackerRecord: Hashable, Codable {
    case record(trackerId: UUID, date: String)

    private enum CodingKeys: String, CodingKey {
        case trackerId, date
        case type
    }

    private enum RecordType: String, Codable {
        case record
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .record(let trackerId, let date):
            try container.encode(RecordType.record, forKey: .type)
            try container.encode(trackerId, forKey: .trackerId)
            try container.encode(date, forKey: .date)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(RecordType.self, forKey: .type)
        
        switch type {
        case .record:
            let trackerId = try container.decode(UUID.self, forKey: .trackerId)
            let date = try container.decode(String.self, forKey: .date)
            self = .record(trackerId: trackerId, date: date)
        }
    }
}
