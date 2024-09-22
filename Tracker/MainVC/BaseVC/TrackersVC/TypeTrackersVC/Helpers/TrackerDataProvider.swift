//
//  TrackerDataProvider.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 16.09.2024.
//

import Foundation

// MARK: - TrackerDataProvider
protocol TrackerDataProvider {
    var numberOfItems: Int { get }
    func item(at index: Int) -> String?
}
