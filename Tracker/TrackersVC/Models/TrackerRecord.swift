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

enum TrackerRecord {
    case record(trackerId: UUID, date: String)
}
