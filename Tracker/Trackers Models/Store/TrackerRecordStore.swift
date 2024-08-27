//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 21.08.2024.
//

import Foundation
import CoreData

final class TrackerRecordStore {
    private let persistentContainer: NSPersistentContainer
    private let fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при загрузке записи из Core Data",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let context = persistentContainer.viewContext
        let recordCoreData = TrackerRecordCoreData(context: context)
        
        recordCoreData.trackerId = record.trackerId
        recordCoreData.date = record.date
        
        try context.save()
    }

    func removeRecord(for trackerId: UUID, on date: String) throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", trackerId as CVarArg, date)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let recordToDelete = results.first {
                context.delete(recordToDelete)
                try context.save()
            }
        } catch {
            throw error
        }
    }

    func fetchRecords() -> [TrackerRecordCoreData] {
        do {
            try fetchedResultsController.performFetch()
            let recordCoreData = fetchedResultsController.fetchedObjects ?? []
 
            return recordCoreData
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при загрузке записей из Core Data",
                metadata: ["❌": error.localizedDescription]
            )
            return []
        }
    }
}
