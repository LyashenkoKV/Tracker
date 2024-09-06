//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 19.08.2024.
//

import CoreData
import UIKit

final class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                Logger.shared.log(.error,
                                  message: "Ошибка при создании контейнера CoreData",
                                  metadata: ["❌": error.localizedDescription])
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Logger.shared.log(
                    .error, message: "Ошибка сохранения контекста CoreData",
                    metadata: ["❌": error.localizedDescription]
                )
            }
        }
    }
    
    func clearCoreData() {
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        for store in persistentStoreCoordinator.persistentStores {
            guard let storeURL = store.url else { continue }
            
            do {
                try persistentStoreCoordinator.destroyPersistentStore(
                    at: storeURL,
                    ofType: store.type,
                    options: nil
                )
            } catch {
                Logger.shared.log(
                    .error,
                    message: "Не удалось очистить постоянное хранилище CoreData",
                    metadata: ["❌": error.localizedDescription]
                )
            }
            
            do {
                try persistentStoreCoordinator.addPersistentStore(
                    ofType: store.type,
                    configurationName: nil,
                    at: storeURL,
                    options: nil
                )
            } catch {
                Logger.shared.log(
                    .error,
                    message: "Не удалось повторно создать постоянное хранилище CoreData",
                    metadata: ["❌": error.localizedDescription]
                )
            }
        }
    }
}
