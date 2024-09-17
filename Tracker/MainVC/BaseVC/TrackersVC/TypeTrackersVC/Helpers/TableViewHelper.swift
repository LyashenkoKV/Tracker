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
        categories: [TrackerCategory],
        editingCategoryIndex: IndexPath?,
        viewController: BaseTrackerViewController
    ) -> UITableViewCell {
        switch viewControllerType {
        case .typeTrackers:
            return ConfigureTableViewCellsHelper.configureTypeTrackersCell(
                at: indexPath,
                tableView: tableView
            )
        case .creatingTracker, .schedule:
            return UITableViewCell()
        case .category:
            if isAddingCategory {
                
                return ConfigureTableViewCellsHelper.configureTextViewCell(
                    at: indexPath,
                    tableView: tableView,
                    categories: categories,
                    viewController: viewController,
                    editingCategoryIndex: editingCategoryIndex,
                    isAddingCategory: isAddingCategory
                )
            } else {
                return ConfigureTableViewCellsHelper.configureCategoryCell(
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
    
    static func calculateCellHeight(
        for tableView: UITableView,
        itemCount: Int,
        itemsPerRow: Int
    ) -> CGFloat {
        let collectionViewWidth = tableView.frame.width
        let cellSpacing: CGFloat = 5
        let leftInset: CGFloat = 10
        let rightInset: CGFloat = 10

        let totalSpacing = (CGFloat(itemsPerRow - 1) * cellSpacing)
        let totalInsets = leftInset + rightInset
        let availableWidth = collectionViewWidth - totalInsets - totalSpacing
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        
        let numberOfRows = ceil(CGFloat(itemCount) / CGFloat(itemsPerRow))
        let totalHeight = numberOfRows * itemWidth + (numberOfRows - 1) * cellSpacing
        
        return totalHeight + 20
    }
}
