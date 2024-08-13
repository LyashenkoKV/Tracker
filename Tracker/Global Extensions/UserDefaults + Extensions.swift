//
//  UserDefaults + Extensions.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 13.08.2024.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let trackers = "savedTrackers"
    }

    var savedTrackers: [Tracker] {
        get {
            guard let data = data(forKey: Keys.trackers) else { return [] }
            let decoder = JSONDecoder()
            return (try? decoder.decode([Tracker].self, from: data)) ?? []
        }
        set {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(newValue)
            set(data, forKey: Keys.trackers)
        }
    }
}
