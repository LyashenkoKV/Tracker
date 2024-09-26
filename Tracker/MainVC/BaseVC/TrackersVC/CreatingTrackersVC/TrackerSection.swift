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
            return LocalizationKey.emojiHeader.localized()
        case .color:
            return LocalizationKey.colorHeader.localized()
        case .createButtons:
            return nil
        }
    }
    
    var footerTitle: String? {
        switch self {
        case .textView:
            return LocalizationKey.limitChar.localized()
        case .buttons, .emoji, .color, .createButtons:
            return nil
        }
    }
}
