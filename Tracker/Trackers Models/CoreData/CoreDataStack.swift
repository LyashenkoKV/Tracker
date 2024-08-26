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
            } else {
                Logger.shared.log(.info, message: "Успешно загружен persistent store \(storeDescription.url?.absoluteString ?? "Unknown URL")")
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
                Logger.shared.log(.info, message: "Изменения успешно сохранены")
            } catch {
                let nserror = error as NSError
                Logger.shared.log(.error, message: "Ошибка сохранения контекста CoreData: \(nserror.localizedDescription)")
            }
        }
    }
    
    func clearCoreData() {
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        for store in persistentStoreCoordinator.persistentStores {
            guard let storeURL = store.url else { continue }
            
            do {
                try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: store.type, options: nil)
            } catch {
                print("Failed to destroy persistent store: \(error)")
            }
            
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: store.type, configurationName: nil, at: storeURL, options: nil)
            } catch {
                print("Failed to recreate persistent store: \(error)")
            }
        }
    }
}
