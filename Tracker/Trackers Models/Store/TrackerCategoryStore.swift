//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 21.08.2024.
//

import Foundation
import CoreData

final class TrackerCategoryStore: NSObject {
    private let persistentContainer: NSPersistentContainer
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    
    var didUpdateData: (() -> Void)?

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: "title",
            cacheName: nil
        )
        
        super.init()
        fetchedResultsController.delegate = self

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
        
        // Проверка на существование категории
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        let existingCategories = try context.fetch(fetchRequest)
        
        if existingCategories.first != nil {
            Logger.shared.log(.info, message: "Категория \(category.title) уже существует, использование существующей категории.")
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        try context.save()
        Logger.shared.log(.info, message: "Категория успешно сохранена в Core Data: \(category.title)")
        
        try fetchedResultsController.performFetch()
        Logger.shared.log(.info, message: "Обновление NSFetchedResultsController выполнено после добавления категории.")
        
        DispatchQueue.main.async {
            self.didUpdateData?()
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let categoryToDelete = results.first {
                context.delete(categoryToDelete)
                try context.save()
                
                Logger.shared.log(.info, message: "Категория \(category.title) успешно удалена из Core Data")
                
                try fetchedResultsController.performFetch()
                Logger.shared.log(.info, message: "Обновление NSFetchedResultsController после удаления категории выполнено")
            }
        } catch {
            Logger.shared.log(.error, message: "Ошибка при удалении категории \(category.title) из Core Data: \(error.localizedDescription)")
            throw error
        }
        
        DispatchQueue.main.async {
            self.didUpdateData?()
        }
    }
    
    func fetchCategories() -> [TrackerCategory] {
        Logger.shared.log(.info, message: "Попытка загрузки категорий из Core Data")
        
        do {
            try fetchedResultsController.performFetch()
            let categoriesCoreData = fetchedResultsController.fetchedObjects ?? []
            Logger.shared.log(.info, message: "Категории успешно загружены, всего категорий: \(categoriesCoreData.count)")
            
            return categoriesCoreData.map { TrackerCategory(from: $0) }
        } catch {
            Logger.shared.log(.error, message: "Ошибка при загрузке категорий из Core Data: \(error.localizedDescription)")
            return []
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didUpdateData?()
    }
}
