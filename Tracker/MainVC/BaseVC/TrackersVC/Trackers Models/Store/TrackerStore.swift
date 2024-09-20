//
//  TrackerStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 21.08.2024.
//

import Foundation
import CoreData

final class TrackerStore: NSObject {
    private let persistentContainer: NSPersistentContainer
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
                message: "Не удалось получить данные",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func addTracker(_ tracker: Tracker) throws {
        let context = persistentContainer.viewContext
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.isRegularEvent = tracker.isRegularEvent
        trackerCoreData.creationDate = tracker.creationDate
        trackerCoreData.isPinned = false
        
        trackerCoreData.categoryTitle = tracker.isPinned
        ? NSLocalizedString(
            "pinned_category",
            comment: "Закрепленные"
        )
        : tracker.categoryTitle
        
        trackerCoreData.originalCategoryTitle = tracker.originalCategoryTitle ?? tracker.categoryTitle
        
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", tracker.categoryTitle)
        
        do {
            let categories = try context.fetch(fetchRequest)
            
            if let existingCategory = categories.first {
                trackerCoreData.categoryTitle = existingCategory.title
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = tracker.categoryTitle
                trackerCoreData.categoryTitle = newCategory.title
            }
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при поиске или создании категории",
                metadata: ["❌": error.localizedDescription]
            )
            throw error
        }
        
        if let scheduleData = try? JSONEncoder().encode(tracker.schedule),
           let scheduleString = String(data: scheduleData, encoding: .utf8) {
            trackerCoreData.schedule = scheduleString
        } else {
            Logger.shared.log(
                .error,
                message: "Ошибка сериализации расписания для трекера",
                metadata: ["❌": "\(tracker.name)"]
            )
        }
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }
    
    func deleteTracker(withId id: UUID) throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let trackerToDelete = try context.fetch(fetchRequest).first {
                context.delete(trackerToDelete)
                try context.save()
            } else {
                Logger.shared.log(
                    .error,
                    message: "Трекер с ID \(id) не найден",
                    metadata: ["❌": "Удаление не выполнено"]
                )
            }
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при удалении трекера с ID \(id)",
                metadata: ["❌": error.localizedDescription]
            )
            throw error
        }
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        do {
            if let trackerCoreData = try context.fetch(fetchRequest).first {
                trackerCoreData.name = tracker.name
                trackerCoreData.color = tracker.color
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.isPinned = tracker.isPinned
                
                let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "title == %@", tracker.categoryTitle)
                
                let categories = try context.fetch(categoryFetchRequest)

                if let category = categories.first {
                    trackerCoreData.categoryTitle = category.title
                } else {
                    let newCategory = TrackerCategoryCoreData(context: context)
                    newCategory.title = tracker.categoryTitle
                    trackerCoreData.categoryTitle = newCategory.title
                }

                do {
                    let scheduleData = try JSONEncoder().encode(tracker.schedule)
                    trackerCoreData.schedule = String(data: scheduleData, encoding: .utf8)
                } catch {
                    Logger.shared.log(
                        .error,
                        message: "Ошибка сериализации расписания при обновлении трекера: \(tracker.name)", metadata: ["❌": error.localizedDescription]
                    )
                    throw error
                }

                try context.save()
            } else {
                Logger.shared.log(.error, message: "Трекер не найден для обновления: \(tracker.id)")
            }
        } catch {
            Logger.shared.log(.error, message: "Ошибка при обновлении трекера: \(tracker.name)", metadata: ["❌": error.localizedDescription])
            throw error
        }
    }

    func fetchTrackers() -> [TrackerCoreData] {
        do {
            try fetchedResultsController.performFetch()
            let trackers = fetchedResultsController.fetchedObjects ?? []
            return trackers
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при загрузке трекеров из Core Data",
                metadata: ["❌": error.localizedDescription]
            )
            return []
        }
    }
    
    func fetchTrackers(predicate: NSPredicate? = nil) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.shared.log(.error, message: "Ошибка при выборке трекеров: \(error.localizedDescription)")
        }
    }
}
