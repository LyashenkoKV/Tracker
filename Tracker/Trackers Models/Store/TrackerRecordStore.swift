//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 21.08.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func addRecord(trackerId: UUID, date: String) {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date
        saveContext()
    }

    func fetchRecords(for trackerId: UUID) -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        do {
            return try context.fetch(request)
        } catch {
            Logger.shared.log(.error,
                              message: "TrackerRecordStore: Не удалось получить записи",
                              metadata: ["❌": error.localizedDescription])
            return []
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
            Logger.shared.log(.error,
                              message: "TrackerRecordStore: Ошибка сохрания контекста",
                              metadata: ["❌": error.localizedDescription])
        }
    }
}
