//
//  TableViewHelper.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 05.09.2024.
//

import UIKit

// MARK: - TableViewHelper
final class TableViewHelper {
    static func numberOfRows(
        in viewControllerType: TrackerViewControllerType?,
        section: Int,
        dataProvider: TrackerDataProvider?,
        isAddingCategory: Bool
    ) -> Int {
        switch viewControllerType {
        case .typeTrackers:
            return 1
        case .creatingTracker:
            return 0
        case .category:
            return isAddingCategory ? 1 : (dataProvider?.numberOfItems ?? 0)
        case .schedule:
            return DayOfTheWeek.allCases.count
        case .none:
            return 0
        }
    }
    
    static func cellForRow(
        at indexPath: IndexPath,
        viewControllerType: TrackerViewControllerType?,
        tableView: UITableView,
        dataProvider: TrackerDataProvider?,
        isAddingCategory: Bool,
        selectedCategory: TrackerCategory?,
        categories: [TrackerCategory]
    ) -> UITableViewCell {
        switch viewControllerType {
        case .typeTrackers:
            return configureTypeTrackersCell(at: indexPath, tableView: tableView)
        case .creatingTracker, .schedule:
            return UITableViewCell()
        case .category:
            if isAddingCategory {
                return configureTextViewCell(
                    at: indexPath,
                    tableView: tableView,
                    categories: categories
                )
            } else {
                return configureCategoryCell(
                    at: indexPath,
                    tableView: tableView,
                    dataProvider: dataProvider,
                    categories: categories,
                    selectedCategory: selectedCategory
                )
            }
        case .none:
            return UITableViewCell()
        }
    }
    
    private static func configureTypeTrackersCell(
        at indexPath: IndexPath,
        tableView: UITableView
    ) -> UITableViewCell {
        let cell = UITableViewCell()
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            if indexPath.section == 0 {
                content.text = "Привычка"
            } else if indexPath.section == 1 {
                content.text = "Нерегулярное событие"
            }
            content.textProperties.alignment = .center
            content.textProperties.color = .ypBackground
            content.textProperties.font = UIFont.systemFont(
                ofSize: 16,
                weight: .medium
            )
            cell.contentConfiguration = content
        } else {
            if indexPath.section == 0 {
                cell.textLabel?.text = "Привычка"
            } else if indexPath.section == 1 {
                cell.textLabel?.text = "Нерегулярное событие"
            }
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(
                ofSize: 16,
                weight: .medium
            )
            cell.textLabel?.textColor = .ypBackground
        }
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBlack
        return cell
    }
    

    private static func configureCategoryCell(
        at indexPath: IndexPath,
        tableView: UITableView, 
        dataProvider: TrackerDataProvider?,
        categories: [TrackerCategory],
        selectedCategory: TrackerCategory?
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        //let category = categories[indexPath.row]
        guard let itemTitle = dataProvider?.item(at: indexPath.row) else {
            print("Ошибка: itemTitle отсутствует для индекса \(indexPath.row)")
            return UITableViewCell()
        }
        print("Категория на индексе \(indexPath.row): \(itemTitle)")
        cell.configure(with: itemTitle)
        
        if let selectedCategory = selectedCategory, selectedCategory.title == itemTitle {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
//        configureBaseCell(cell, at: indexPath, totalRows: dataProvider?.numberOfItems ?? 0)
//        configureSeparator(cell, isLastRow: indexPath.row == (dataProvider?.numberOfItems ?? 0) - 1)
        return cell
    }

    private static func configureTextViewCell(
        at indexPath: IndexPath,
        tableView: UITableView,
        categories: [TrackerCategory]
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TextViewCell.reuseIdentifier,
            for: indexPath
        ) as? TextViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }

    static func didSelectRow(
        at indexPath: IndexPath,
        viewControllerType: TrackerViewControllerType?,
        viewController: BaseTrackerViewController
    ) {
        switch viewControllerType {
        case .typeTrackers:
            viewController.handleTypeTrackersSelection(at: indexPath)
        case .creatingTracker:
            viewController.handleCreatingTrackerSelection(at: indexPath)
        case .category:
            viewController.handleCategorySelection(at: indexPath)
        case .schedule:
            break
        case .none:
            break
        }
    }
}
