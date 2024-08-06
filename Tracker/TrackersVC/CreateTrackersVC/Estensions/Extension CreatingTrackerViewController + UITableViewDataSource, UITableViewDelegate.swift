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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trackerSection = TrackerSection(rawValue: section) else {
            return 0
        }
        switch trackerSection {
        case .textView:
            return 1
        case .buttons:
            return 2
        case .emoji, .color:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let trackerSection = TrackerSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch trackerSection {
        case .textView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.reuseIdentifier, for: indexPath) as? TextViewCell else {
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

        case .emoji, .color:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            configureDefaultCell(cell, for: trackerSection)
            return cell
        }
    }

    private func configureButtonCell(_ cell: ButtonCell, at indexPath: IndexPath) {
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        cell.accessoryType = .disclosureIndicator
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = indexPath.row == 0 ? "Категория" : "Расписание"
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
        }
    }

    private func configureDefaultCell(_ cell: UITableViewCell, for section: TrackerSection) {
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = section.headerTitle
            content.textProperties.color = .ypBlack
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = section.headerTitle
        }
    }
}
