//
//  TrackerStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 21.08.2024.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func addTracker(
        name: String,
        color: UIColor,
        emoji: String,
        schedule: [DayOfTheWeek],
        categoryTitle: String,
        isRegularEvent: Bool,
        creationDate: Date
    ) {
        let tracker = TrackerCoreData(context: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.color = color.toHexString()
        tracker.emoji = emoji
        tracker.schedule = schedule.map { $0.rawValue } as NSObject
        tracker.categoryTitle = categoryTitle
        tracker.isRegularEvent = isRegularEvent
        tracker.creationDate = creationDate
        
        saveContext()
    }

    func fetchTrackers() -> [TrackerCoreData] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            Logger.shared.log(.error,
                              message: "TrackerStore: Не удалось получить трекеры",
                              metadata: ["❌": error.localizedDescription])
            return []
        }
    }

    func deleteTracker(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
            Logger.shared.log(.error,
                              message: "TrackerStore: Ошибка сохрания контекста",
                              metadata: ["❌": error.localizedDescription])
        }
    }
}
