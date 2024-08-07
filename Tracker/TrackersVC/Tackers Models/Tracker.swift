//
//  Tracker.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import UIKit

//struct Tracker {
//    let id: UUID
//    let name: String
//    let color: UIColor
//    let emoji: String
//    let schedule: Schedule
//}

enum Tracker {
    case tracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: Schedule)
}
