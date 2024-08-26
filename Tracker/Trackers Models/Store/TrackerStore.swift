//
//  TrackerStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 21.08.2024.
//

import Foundation
import CoreData

final class TrackerStore {
    private let persistentContainer: NSPersistentContainer
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>

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
            Logger.shared.log(.error, message: "Не удалось получить данные: \(error.localizedDescription)")
            fatalError("Не удалось получить данные: \(error)")
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
        
        // Поиск или создание категории
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
                Logger.shared.log(.info, message: "Создана новая категория: \(newCategory.title)")
            }
        } catch {
            Logger.shared.log(.error, message: "Ошибка при поиске или создании категории: \(error.localizedDescription)")
            throw error
        }
        
        // Сохранение расписания
        if let scheduleData = try? JSONEncoder().encode(tracker.schedule) {
            trackerCoreData.schedule = scheduleData as NSData
            Logger.shared.log(.info, message: "Расписание успешно сериализовано для трекера: \(tracker.name)")
        } else {
            Logger.shared.log(.error, message: "Ошибка сериализации расписания для трекера: \(tracker.name)")
        }

        do {
            try context.save()
            Logger.shared.log(.info, message: "Трекер успешно сохранен в Core Data: \(tracker.name)")
        } catch {
            Logger.shared.log(.error, message: "Ошибка при сохранении трекера в Core Data: \(tracker.name) - \(error)")
            throw error
        }
    }

    func fetchTrackers() -> [TrackerCoreData] {
        do {
            Logger.shared.log(.info, message: "Попытка загрузки трекеров из Core Data")
            try fetchedResultsController.performFetch()
            Logger.shared.log(.info, message: "Трекеры успешно загружены из Core Data, всего загружено: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
        } catch {
            Logger.shared.log(.error, message: "Ошибка при загрузке трекеров из Core Data: \(error)")
        }
        return fetchedResultsController.fetchedObjects ?? []
    }
}
