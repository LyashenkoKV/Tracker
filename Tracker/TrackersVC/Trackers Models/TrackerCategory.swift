//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import Foundation

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    init(from coreData: TrackerCategoryCoreData) {
        self.title = coreData.title ?? "Без названия"
        self.trackers = (coreData.trackers?.allObjects as? [TrackerCoreData])?.map { Tracker(from: $0) } ?? []
    }
}
