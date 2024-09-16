//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 04.09.2024.
//

import Foundation

final class CategoryViewModel: TrackerDataProvider {
    private let trackerCategoryStore: TrackerCategoryStore
    
    var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?(categories)
        }
    }
    
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onAddCategoryButtonStateUpdated: ((Bool) -> Void)?
    var onPlaceholderStateUpdated: ((Bool) -> Void)?
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        
        self.trackerCategoryStore.didUpdateData = { [weak self] in
            self?.loadCategories()
        }
    }
    
    func loadCategories() {
        categories = trackerCategoryStore.fetchCategories()
        updatePlaceholder()
    }
    
    func addCategory(named name: String) {
        guard !name.isEmpty else {
            return
        }
        
        do {
            try trackerCategoryStore.addCategory(TrackerCategory(title: name, trackers: []))
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при добавлении категории:",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func deleteCategory(at index: Int) {
        guard categories.indices.contains(index) else {
            return
        }

        let categoryToDelete = categories[index]
        do {
            try trackerCategoryStore.deleteCategory(categoryToDelete)

            categories.remove(at: index)
            onCategoriesUpdated?(categories)
            
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при удалении категории \(categoryToDelete.title)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func updateAddCategoryButtonState(isEnabled: Bool) {
        onAddCategoryButtonStateUpdated?(isEnabled)
    }
    
    func updatePlaceholder() {
        let isPlaceholderVisible = categories.isEmpty
        onPlaceholderStateUpdated?(isPlaceholderVisible)
    }
    
    // MARK: - TrackerDataProvider
    var numberOfItems: Int {
        return categories.count
    }
    
    func item(at index: Int) -> String {
        return categories[index].title
    }
}
