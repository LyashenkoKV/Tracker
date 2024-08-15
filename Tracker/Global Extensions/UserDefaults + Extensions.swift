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
        static let completedTrackers = "completedTrackers"
    }

    func saveTrackers(_ trackers: [Tracker]) {
        var existingTrackers = loadTrackers()
        existingTrackers.append(contentsOf: trackers)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(existingTrackers)
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
    
    func saveCompletedTrackers(_ completedTrackers: Set<TrackerRecord>) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(completedTrackers)
            set(data, forKey: Keys.completedTrackers)
        } catch {
            print("Failed to encode completed trackers: \(error)")
        }
    }
    
    func loadCompletedTrackers() -> Set<TrackerRecord> {
        guard let data = data(forKey: Keys.completedTrackers) else {
            return []
        }
        let decoder = JSONDecoder()
        do {
            let completedTrackers = try decoder.decode(Set<TrackerRecord>.self, from: data)
            return completedTrackers
        } catch {
            print("Failed to decode completed trackers: \(error)")
            return []
        }
    }
    
    func removeTrackers() {
        removeObject(forKey: Keys.trackers)
    }

    func removeCompletedTrackers() {
        removeObject(forKey: Keys.completedTrackers)
    }
}
