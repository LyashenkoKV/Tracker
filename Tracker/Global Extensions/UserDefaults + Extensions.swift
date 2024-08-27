////
////  UserDefaults + Extensions.swift
////  Tracker
////
////  Created by Konstantin Lyashenko on 13.08.2024.
////
//
//import Foundation
//
//extension UserDefaults {
//    private enum Keys {
//        static let trackers = "savedTrackers"
//        static let completedTrackers = "completedTrackers"
//        static let savedCategories = "savedCategories"
//        static let selectedDays = "selectedDays"
//    }
//
//    func saveTrackers(_ trackers: [Tracker]) {
//        let encoder = JSONEncoder()
//        do {
//            let data = try encoder.encode(trackers)
//            set(data, forKey: Keys.trackers)
//        } catch {
//            print("Failed to encode trackers: \(error)")
//        }
//    }
//
//    func loadTrackers() -> [Tracker] {
//        guard let data = data(forKey: Keys.trackers) else {
//            return []
//        }
//        let decoder = JSONDecoder()
//        do {
//            let trackers = try decoder.decode([Tracker].self, from: data)
//            return trackers
//        } catch {
//            print("Failed to decode trackers: \(error)")
//            return []
//        }
//    }
//
//    func saveCompletedTrackers(_ completedTrackers: Set<TrackerRecord>) {
//        let encoder = JSONEncoder()
//        do {
//            let data = try encoder.encode(completedTrackers)
//            set(data, forKey: Keys.completedTrackers)
//        } catch {
//            print("Failed to encode completed trackers: \(error)")
//        }
//    }
//
//    func loadCompletedTrackers() -> Set<TrackerRecord> {
//        guard let data = data(forKey: Keys.completedTrackers) else {
//            return []
//        }
//        let decoder = JSONDecoder()
//        do {
//            let completedTrackers = try decoder.decode(Set<TrackerRecord>.self, from: data)
//            return completedTrackers
//        } catch {
//            print("Failed to decode completed trackers: \(error)")
//            return []
//        }
//    }
//
//    func savedCategories(_ categories: [TrackerCategory]) {
//        let encoder = JSONEncoder()
//        do {
//            let data = try encoder.encode(categories)
//            set(data, forKey: Keys.savedCategories)
//        } catch {
//            print("Failed to encode categories: \(error)")
//        }
//    }
//
//    func loadCategories() -> [TrackerCategory] {
//        guard let data = data(forKey: Keys.savedCategories) else {
//            return []
//        }
//        let decoder = JSONDecoder()
//        do {
//            let categories = try decoder.decode([TrackerCategory].self, from: data)
//            return categories
//        } catch {
//            print("Failed to decode categories: \(error)")
//            return []
//        }
//    }
//    
//    func clearSavedData() {
//        UserDefaults.standard.removeObject(forKey: "selectedCategory")
//        UserDefaults.standard.removeObject(forKey: "selectedDays")
//    }
//}
