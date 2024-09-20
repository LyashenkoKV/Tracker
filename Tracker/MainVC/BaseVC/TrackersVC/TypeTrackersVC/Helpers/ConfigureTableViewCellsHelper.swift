//
//  ConfigureTableViewCellsHelper.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.09.2024.
//

import UIKit

// MARK: - ConfigureTableViewCellsHelper
final class ConfigureTableViewCellsHelper {
    
    static func configureTypeTrackersCell(
        at indexPath: IndexPath,
        tableView: UITableView
    ) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            if indexPath.section == 0 {
                content.text = NSLocalizedString(
                    "habit",
                    comment: "Привычка"
                )
            } else if indexPath.section == 1 {
                content.text = NSLocalizedString(
                    "irregular_event",
                    comment: "Нерегулярное событие"
                )
            }
            content.textProperties.alignment = .center
            content.textProperties.color = .ypBackground
            content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            cell.contentConfiguration = content
        } else {
            if indexPath.section == 0 {
                cell.textLabel?.text = NSLocalizedString(
                    "habit",
                    comment: "Привычка"
                )
            } else if indexPath.section == 1 {
                cell.textLabel?.text = NSLocalizedString(
                    "irregular_event",
                    comment: "Нерегулярное событие"
                )
            }
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            cell.textLabel?.textColor = .ypBackground
        }
        
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBlack
        return cell
    }
    
    static func configureCategoryCell(
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
        
        guard let itemTitle = dataProvider?.item(at: indexPath.row) else {
            print("Ошибка: itemTitle отсутствует для индекса \(indexPath.row)")
            return UITableViewCell()
        }
        
        cell.configure(with: itemTitle)
        
        if let selectedCategory = selectedCategory, selectedCategory.title == itemTitle {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        configureBaseCell(
            cell,
            at: indexPath,
            totalRows: dataProvider?.numberOfItems ?? 0
        )
        configureSeparator(
            cell,
            isLastRow: indexPath.row == (dataProvider?.numberOfItems ?? 0) - 1
        )
        
        return cell
    }
    
    static func configureTextViewCell(at indexPath: IndexPath,
                                      tableView: UITableView,
                                      categories: [TrackerCategory],
                                      viewController: BaseTrackerViewController,
                                      editingCategoryIndex: IndexPath?
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TextViewCell.reuseIdentifier,
            for: indexPath
        ) as? TextViewCell else {
            return UITableViewCell()
        }
        cell.delegate = viewController
        
        if let editingIndex = editingCategoryIndex {
            guard editingIndex.row < categories.count else {
                Logger.shared.log(
                    .error,
                    message: "Ошибка: индекс \(editingIndex.row) выходит за пределы массива категорий."
                )
                return UITableViewCell()
            }
            
            cell.changeText(categories[editingIndex.row].title, editing: true)
            
            viewController.title = NSLocalizedString(
                "edit_category",
                comment: "Редактирование категории"
            )
        } else {
            cell.changeText(
                NSLocalizedString(
                    "enter_cat_name",
                    comment: "Введите название категории"
                ),
                editing: false
            )
            viewController.title = NSLocalizedString(
                "new_category",
                comment: "Новая категория"
            )
        }
        
        configureBaseCell(cell, at: indexPath, totalRows: 1)
        configureSeparator(cell, isLastRow: true)
        
        return cell
    }
    
    static func configureTextViewCell(
        for tableView: UITableView,
        at indexPath: IndexPath,
        delegate: TextViewCellDelegate,
        trackerToEdit: Tracker?
    ) -> TextViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TextViewCell.reuseIdentifier,
            for: indexPath
        ) as? TextViewCell else {
            return TextViewCell()
        }
        
        if let trackerToEdit = trackerToEdit {
            cell.changeText(
                trackerToEdit.name,
                editing: true
            )
        }
        
        cell.delegate = delegate
        cell.selectionStyle = .none
        return cell
    }
    
    static func configureBaseCell(
        _ cell: UITableViewCell,
        at indexPath: IndexPath,
        totalRows: Int
    ) {
        cell.layer.masksToBounds = true
        cell.backgroundColor = .ypWhiteGray
        cell.selectionStyle = .none
        cell.tintColor = .systemBlue
        
        if totalRows == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        } else if indexPath.row == totalRows - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        } else {
            cell.layer.cornerRadius = 0
        }
    }
    
    static func configureButtonCell(
        _ cell: UITableViewCell,
        at indexPath: IndexPath,
        isSingleCell: Bool,
        isAddingCategory: Bool,
        selectedCategory: TrackerCategory?,
        selectedDaysString: String
    ) {
        cell.accessoryType = .disclosureIndicator
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = indexPath.row == 0
            ? NSLocalizedString("category", comment: "Категория")
            : NSLocalizedString("schedule", comment: "Расписание")
            content.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            content.textProperties.adjustsFontSizeToFitWidth = true
            content.textProperties.minimumScaleFactor = 0.8
            
            if indexPath.row == 0 && !isAddingCategory {
                if let category = selectedCategory {
                    content.secondaryText = category.title
                }
            } else {
                content.secondaryText = selectedDaysString
            }
            
            content.secondaryTextProperties.color = .ypGray
            content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            content.secondaryTextProperties.adjustsFontSizeToFitWidth = true
            content.secondaryTextProperties.minimumScaleFactor = 0.8
            
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = indexPath.row == 0
            ? NSLocalizedString("category", comment: "Категория")
            : NSLocalizedString("schedule", comment: "Расписание")
            cell.detailTextLabel?.textColor = .ypGray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
            cell.detailTextLabel?.minimumScaleFactor = 0.8
            cell.detailTextLabel?.lineBreakMode = .byTruncatingTail
            
            if indexPath.row == 0 && !isAddingCategory {
                if let category = selectedCategory {
                    cell.detailTextLabel?.text = category.title
                }
            } else {
                cell.detailTextLabel?.text = selectedDaysString
            }
        }
    }
    
    static func configureSeparator(
        _ cell: UITableViewCell,
        isLastRow: Bool
    ) {
        cell.contentView.subviews.filter { $0.tag == 1001 }.forEach { $0.removeFromSuperview() }
        
        guard !isLastRow else { return }
        
        let separator = UIView()
        separator.tag = 1001
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
    }
    
    static func configureEmojiAndColorCell(
        for tableView: UITableView,
        at indexPath: IndexPath,
        with items: [String],
        isEmoji: Bool,
        selectedElement: String?
    ) -> EmojiesAndColorsTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiesAndColorsTableViewCell else {
            return EmojiesAndColorsTableViewCell()
        }
        cell.configure(with: items, isEmoji: isEmoji, selectedElement: selectedElement)
        cell.selectionStyle = .none
        return cell
    }
    
    static func configureCreateButtonsCell(
        for tableView: UITableView,
        at indexPath: IndexPath,
        onCreateTapped: @escaping () -> Void,
        onCancelTapped: @escaping () -> Void,
        isEditing: Bool
    ) -> CreateButtonsViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CreateButtonsViewCell.reuseIdentifier,
            for: indexPath
        ) as? CreateButtonsViewCell else {
            return CreateButtonsViewCell()
        }
        
        cell.onCreateButtonTapped = onCreateTapped
        cell.onCancelButtonTapped = onCancelTapped
        
        cell.updateCreateButtonTitle(isEditing: isEditing)
        
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - Header Configuration
    static func configureCounterHeaderView(
        with daysCount: Int
    ) -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let counterLabel = UILabel()
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.textColor = .ypBlack
        counterLabel.font = UIFont.boldSystemFont(ofSize: 32)
        counterLabel.textAlignment = .center
        
        counterLabel.text = getLocalizedDayString(for: daysCount)
        
        headerView.addSubview(counterLabel)
        
        NSLayoutConstraint.activate([
            counterLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            counterLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 25),
            counterLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -40)
        ])
        
        return headerView
    }
    
    static func getLocalizedDayString(for countDays: Int) -> String {
        let localizedFormat = NSLocalizedString("day_count", comment: "")
        return String.localizedStringWithFormat(localizedFormat, countDays)
    }
    
    static func configureTextHeaderView(
        title: String
    ) -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = .ypBlack
        headerLabel.font = UIFont.boldSystemFont(ofSize: 19)
        headerLabel.text = title
        
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        return headerView
    }
}
