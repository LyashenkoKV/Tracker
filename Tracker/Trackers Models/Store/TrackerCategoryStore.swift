//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 21.08.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func addCategory(title: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        saveContext()
    }

    func fetchCategories() -> [TrackerCategoryCoreData] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            Logger.shared.log(.error,
                              message: "TrackerCategoryStore: Не удалось получить категории",
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
                              message: "TrackerCategoryStore: Ошибка сохрания контекста",
                              metadata: ["❌": error.localizedDescription])
        }
    }
}
