//
//  TrackerSection.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import Foundation

enum TrackerSection: Int, CaseIterable {
    case textView
    case buttons
    case emoji
    case color
    case createButtons

    var headerTitle: String? {
        switch self {
        case .textView:
            return nil
        case .buttons:
            return nil
        case .emoji:
            return NSLocalizedString(
                "emoji_header",
                comment: "emoji"
            )
        case .color:
            return NSLocalizedString(
                "color_header",
                comment: "Цвет"
            )
        case .createButtons:
            return nil
        }
    }
    
    var footerTitle: String? {
        switch self {
        case .textView:
            return NSLocalizedString(
                "limit_char",
                comment: "Ограничение 38 символов"
            )
        case .buttons, .emoji, .color, .createButtons:
            return nil
        }
    }
}
