//
//  CreateTrackerViewController + UICollectionViewDataSource.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

extension CreatingTrackerViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return TrackerSection.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        guard let trackerSection = TrackerSection(rawValue: section) else {
            return 0
        }
        switch trackerSection {
        case .textView:
            return 1
        case .buttons:
            return 2
        case .emoji, .color, .createButtons:
            return 1
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let trackerSection = TrackerSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch trackerSection {
        case .textView:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TextViewCell.reuseIdentifier,
                for: indexPath
            ) as? TextViewCell else {
                return UITableViewCell()
            }
            cell.backgroundColor = .clear
            return cell

        case .buttons:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ButtonCell.reuseIdentifier,
                for: indexPath
            ) as? ButtonCell else {
                return UITableViewCell()
            }
            configureButtonCell(cell, at: indexPath)
            
            return cell
            
        case .emoji:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CollectionTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? CollectionTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: emojies, isEmoji: true)
            return cell
            
        case .color:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CollectionTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? CollectionTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: colors, isEmoji: false)
            return cell
            
        case .createButtons:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CreateButtonsViewCell.reuseIdentifier,
                for: indexPath
            ) as? CreateButtonsViewCell else {
                return UITableViewCell()
            }
            configureDefaultCell(cell, for: trackerSection)
            cell.backgroundColor = .clear
            return cell
        }
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let trackerSection = TrackerSection(rawValue: indexPath.section) else {
            return UITableView.automaticDimension
        }
        
        switch trackerSection {
        case .textView:
            return UITableView.automaticDimension
        case .buttons:
            return UITableView.automaticDimension
        case .emoji, .color:
            return 200
        case .createButtons:
            return UITableView.automaticDimension
        }
    }
    
    private func configureButtonCell(
        _ cell: ButtonCell,
        at indexPath: IndexPath) {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 15
            if indexPath.row == 0 {
                cell.layer.maskedCorners = [
                    .layerMinXMinYCorner,
                    .layerMaxXMinYCorner
                ]
            } else {
                cell.layer.maskedCorners = [
                    .layerMinXMaxYCorner,
                    .layerMaxXMaxYCorner
                ]
            }
            cell.accessoryType = .disclosureIndicator
            if #available(iOS 14.0, *) {
                var content = cell.defaultContentConfiguration()
                content.text = indexPath.row == 0 ? "Категория" : "Расписание"
                cell.contentConfiguration = content
            } else {
                cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
            }
            
            let separator = UIView(frame: CGRect(
                x: 20,
                y: cell.frame.height - 1,
                width: cell.frame.width,
                height: 1)
            )
            separator.backgroundColor = .lightGray
            if indexPath.row == 0 {
                cell.addSubview(separator)
            }
        }
    
    private func configureDefaultCell(
        _ cell: UITableViewCell,
        for section: TrackerSection) {
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = section.headerTitle
            content.textProperties.color = .ypBlack
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = section.headerTitle
        }
        }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let trackerSection = TrackerSection(rawValue: section) else {
            return nil
        }
        return trackerSection.headerTitle
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let trackerSection = TrackerSection(rawValue: section), trackerSection.headerTitle != nil else {
            return 0
        }
        return 44
    }
}
