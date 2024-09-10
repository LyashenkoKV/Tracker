//
//  HandleActionsHelper.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.09.2024.
//

import UIKit

final class HandleActionsHelper {
    
    static func handleTypeTrackersSelection(
        at indexPath: IndexPath,
        viewController: BaseTrackerViewController
    ) {
        if indexPath.section == 0 {
            let creatingTrackerVC = CreatingTrackerViewController(type: .creatingTracker, isRegularEvent: true)
            let navController = UINavigationController(rootViewController: creatingTrackerVC)
            navController.modalPresentationStyle = .formSheet
            viewController.present(navController, animated: true)
        } else if indexPath.section == 1 {
            let irregularEventVC = CreatingTrackerViewController(type: .creatingTracker, isRegularEvent: false)
            irregularEventVC.title = NSLocalizedString(
                "irregular_event",
                comment: "Нерегулярное событие"
            )
            let navController = UINavigationController(rootViewController: irregularEventVC)
            navController.modalPresentationStyle = .formSheet
            viewController.present(navController, animated: true)
        }
    }

    static func handleCreatingTrackerSelection(
        at indexPath: IndexPath,
        viewController: BaseTrackerViewController
    ) {
        if indexPath.section == TrackerSection.buttons.rawValue {
            if indexPath.row == 0 {
                let categoryVC = CategoryViewController()
                categoryVC.delegate = viewController as CategorySelectionDelegate
                categoryVC.selectedCategory = viewController.selectedCategory
                let navController = UINavigationController(rootViewController: categoryVC)
                navController.modalPresentationStyle = .formSheet
                viewController.present(navController, animated: true)
            } else if indexPath.row == 1 {
                let scheduleVC = ScheduleViewController(type: .schedule)
                scheduleVC.delegate = viewController as ScheduleSelectionDelegate
                scheduleVC.selectedDays = viewController.selectedDays
                let navController = UINavigationController(rootViewController: scheduleVC)
                navController.modalPresentationStyle = .formSheet
                viewController.present(navController, animated: true)
            } else {
                print("Неизвестный индекс ячейки: \(indexPath.row)")
            }
        }
    }

    static func handleCategorySelection(
        at indexPath: IndexPath,
        viewController: BaseTrackerViewController
    ) {
        if !viewController.isAddingCategory {
            let selectedCategory = viewController.categories[indexPath.row]
            viewController.selectedCategories.append(selectedCategory)
        }
    }
    
    static func handleStartEditingCategory(
        at indexPath: IndexPath,
        viewController: BaseTrackerViewController
    ) {
        guard let dataProvider = viewController.dataProvider, indexPath.row < dataProvider.numberOfItems else {
            print("Ошибка: индекс \(indexPath.row) выходит за пределы источника данных.")
            return
        }

        guard indexPath.row < viewController.categories.count else {
            print("Ошибка: индекс \(indexPath.row) выходит за пределы массива категорий.")
            return
        }

        viewController.editingCategoryIndex = indexPath
        viewController.isAddingCategory = true

        print("Начинаем редактирование категории на индексе \(indexPath.row)")
        viewController.tableView.reloadData()
    }

    static func handleEndEditingCategory(
        _ cell: TextViewCell,
        text: String?,
        viewController: BaseTrackerViewController
    ) {
        guard viewController.isAddingCategory else { return }
        guard let newText = text, !newText.isEmpty else { return }

        let newCategory = TrackerCategory(title: newText, trackers: [])

        if let editingIndex = viewController.editingCategoryIndex {
            guard editingIndex.row < viewController.categories.count else {
                print("Ошибка: индекс \(editingIndex.row) выходит за пределы массива категорий.")
                return
            }
            viewController.categories[editingIndex.row] = newCategory
            viewController.editingCategoryIndex = nil
        } else {
            viewController.categories.append(newCategory)
        }

        viewController.isAddingCategory = false
        viewController.tableView.reloadData()
    }
    
    static func handleEmojiSelected(
        notification: Notification,
        viewController: CreatingTrackerViewController
    ) {
        if let emoji = notification.userInfo?["selectedEmoji"] as? String {
            viewController.selectedEmoji = emoji
            viewController.updateCreateButtonState()
        }
    }
    
    static func handleColorSelected(
        notification: Notification,
        viewController: CreatingTrackerViewController
    ) {
        if let hexColor = notification.userInfo?["selectedColor"] as? String {
            viewController.selectedColor = UIColor(hex: hexColor)
            viewController.updateCreateButtonState()
        }
    }
}
