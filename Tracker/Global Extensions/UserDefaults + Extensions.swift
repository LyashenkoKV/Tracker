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

    func saveTrackers(_ trackers: [Tracker]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(trackers)
            set(data, forKey: Keys.trackers)
        } catch {
            print("Failed to encode trackers: \(error)")
        }
    }

    func loadTrackers() -> [Tracker] {
        guard let data = data(forKey: Keys.trackers) else {
            return []
        }
        let decoder = JSONDecoder()
        do {
            let trackers = try decoder.decode([Tracker].self, from: data)
            return trackers
        } catch {
            print("Failed to decode trackers: \(error)")
            return []
        }
    }
}
