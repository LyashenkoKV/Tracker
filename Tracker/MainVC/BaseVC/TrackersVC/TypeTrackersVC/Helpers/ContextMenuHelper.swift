//
//  ContextMenuHelper.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 05.09.2024.
//

import UIKit

// MARK: - ContextMenuHelper
final class ContextMenuHelper {
    static func contextMenuConfiguration(
        at indexPath: IndexPath,
        viewControllerType: TrackerViewControllerType?,
        dataProvider: TrackerDataProvider?,
        tableView: UITableView,
        viewController: BaseTrackerViewController
    ) -> UIContextMenuConfiguration? {
        switch viewControllerType {
        case .category:
            guard let _ = dataProvider?.item(at: indexPath.row) else {
                return nil
            }
            
            return UIContextMenuConfiguration(actionProvider: { _ in
                let editAction = UIAction(
                    title: LocalizationKey.edit.localized()
                ) { _ in
                    viewController.startEditingCategory(at: indexPath)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
                let deleteAction = UIAction(
                    title: LocalizationKey.delete.localized(),
                    attributes: .destructive) { _ in
                        viewController.deleteCategory(at: indexPath)
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                return UIMenu(title: "", children: [editAction, deleteAction])
            })
        default:
            return nil
        }
    }
}

