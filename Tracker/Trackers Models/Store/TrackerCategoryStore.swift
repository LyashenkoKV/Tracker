//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 21.08.2024.
//

import Foundation
import CoreData

final class TrackerCategoryStore {
    private let persistentContainer: NSPersistentContainer
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()
            Logger.shared.log(.info, message: "Категории успешно загружены из Core Data, всего загружено: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
        } catch {
            Logger.shared.log(.error, message: "Ошибка при загрузке категорий из Core Data: \(error)")
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let context = persistentContainer.viewContext
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        
        categoryCoreData.title = category.title
        Logger.shared.log(.info, message: "Добавляем категорию: \(category.title)")

        do {
            try context.save()
            Logger.shared.log(.info, message: "Категория успешно сохранена в Core Data: \(category.title)")
        } catch {
            Logger.shared.log(.error, message: "Ошибка при сохранении категории в Core Data: \(category.title) - \(error)")
            throw error
        }
    }

    func fetchCategories() -> [TrackerCategoryCoreData] {
        Logger.shared.log(.info, message: "Попытка загрузки категорий из Core Data")
        let categories = fetchedResultsController.fetchedObjects ?? []
        Logger.shared.log(.info, message: "Категории успешно загружены, всего категорий: \(categories.count)")
        return categories
    }
}
