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
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при загрузке категорий из Core Data",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let context = persistentContainer.viewContext
        
        // Проверка на существование категории
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        let existingCategories = try context.fetch(fetchRequest)
        
        if existingCategories.first != nil {
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        try context.save()
        try fetchedResultsController.performFetch()
        
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
                try fetchedResultsController.performFetch()
            }
        } catch {
            Logger.shared.log(
                .error, 
                message: "Ошибка при удалении категории \(category.title) из Core Data",
                metadata: ["❌": error.localizedDescription]
            )
            throw error
        }
        
        DispatchQueue.main.async {
            self.didUpdateData?()
        }
    }
    
    func fetchCategories() -> [TrackerCategory] {
        do {
            try fetchedResultsController.performFetch()
            let categoriesCoreData = fetchedResultsController.fetchedObjects ?? []
            return categoriesCoreData.map { TrackerCategory(from: $0) }
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при загрузке категорий из Core Data",
                metadata: ["❌": error.localizedDescription]
            )
            return []
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didUpdateData?()
    }
}
