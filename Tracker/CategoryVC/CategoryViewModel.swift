//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 04.09.2024.
//

import Foundation

class CategoryViewModel: TrackerDataProvider {
    private let trackerCategoryStore: TrackerCategoryStore
    
    // Свойства для обновлений через биндинги
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
        
        // Подписываемся на изменения данных в хранилище
        self.trackerCategoryStore.didUpdateData = { [weak self] in
            self?.loadCategories()  // обновляем категории при изменении данных
        }
    }
    
    // Метод для загрузки категорий
    func loadCategories() {
        categories = trackerCategoryStore.fetchCategories()
        updatePlaceholder()
    }
    
    // Добавление новой категории
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
    
    // Удаление категории
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
    
    // Обновление состояния кнопки добавления категории
    func updateAddCategoryButtonState(isEnabled: Bool) {
        onAddCategoryButtonStateUpdated?(isEnabled)
    }
    
    // Обновление состояния плейсхолдера
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
