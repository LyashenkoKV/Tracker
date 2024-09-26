//
//  Notification + Extension.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 13.08.2024.
//

import Foundation

extension Notification.Name {
    static let trackerCreated = Notification.Name("trackerCreated")
    static let trackerUpdated = Notification.Name("trackerUpdated")
    static let emojiSelected = Notification.Name("emojiSelected")
    static let colorSelected = Notification.Name("colorSelected")
}
