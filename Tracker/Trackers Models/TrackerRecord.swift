//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import Foundation

struct TrackerRecord: Hashable, Codable {
    let trackerId: UUID
    let date: String
}

extension TrackerRecord {
    init(from coreData: TrackerRecordCoreData) {
        self.trackerId = coreData.trackerId ?? UUID()
        self.date = coreData.date ?? ""
    }
}
