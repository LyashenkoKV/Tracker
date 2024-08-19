//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 19.08.2024.
//

import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
                Logger.shared.log(.error,
                                  message: "CoreDataStack: ошибка при создании контейнера CoreData",
                                  metadata: ["❌": error.localizedDescription])
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                Logger.shared.log(.error,
                                  message: "CoreDataStack: ошибка сохранения контекста CoreData",
                                  metadata: ["❌": error.localizedDescription])
            }
        }
    }
}
