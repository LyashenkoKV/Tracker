//
//  CreateTrackerViewController + UICollectionViewDataSource.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//
import UIKit

//extension CreatingTrackerViewController: UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return TrackerSection.allCases.count
//    }
//    
//    func tableView(
//        _ tableView: UITableView,
//        numberOfRowsInSection section: Int) -> Int {
//            guard let trackerSection = TrackerSection(rawValue: section) else {
//                return 0
//            }
//            switch trackerSection {
//            case .textView:
//                return 1
//            case .buttons:
//                return 2
//            case .emoji, .color, .createButtons:
//                return 1
//            }
//        }
//    
//    func tableView(
//        _ tableView: UITableView,
//        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            guard let trackerSection = TrackerSection(rawValue: indexPath.section) else {
//                return UITableViewCell()
//            }
//            
//            switch trackerSection {
//            case .textView:
//                guard let cell = tableView.dequeueReusableCell(
//                    withIdentifier: TextViewCell.reuseIdentifier,
//                    for: indexPath
//                ) as? TextViewCell else {
//                    return UITableViewCell()
//                }
//                cell.delegate = self
//                cell.backgroundColor = .clear
//                cell.selectionStyle = .none
//                return cell
//                
//            case .buttons:
//                guard let cell = tableView.dequeueReusableCell(
//                    withIdentifier: ButtonCell.reuseIdentifier,
//                    for: indexPath
//                ) as? ButtonCell else {
//                    return UITableViewCell()
//                }
//                configureButtonCell(cell, at: indexPath)
//                cell.selectionStyle = .none
//                return cell
//                
//            case .emoji:
//                guard let cell = tableView.dequeueReusableCell(
//                    withIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier,
//                    for: indexPath
//                ) as? EmojiesAndColorsTableViewCell else {
//                    return UITableViewCell()
//                }
//                cell.configure(with: emojies, isEmoji: true)
//                cell.selectionStyle = .none
//                return cell
//                
//            case .color:
//                guard let cell = tableView.dequeueReusableCell(
//                    withIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier,
//                    for: indexPath
//                ) as? EmojiesAndColorsTableViewCell else {
//                    return UITableViewCell()
//                }
//                cell.configure(with: colors, isEmoji: false)
//                cell.selectionStyle = .none
//                return cell
//                
//            case .createButtons:
//                guard let cell = tableView.dequeueReusableCell(
//                    withIdentifier: CreateButtonsViewCell.reuseIdentifier,
//                    for: indexPath
//                ) as? CreateButtonsViewCell else {
//                    return UITableViewCell()
//                }
//                cell.selectionStyle = .none
//                cell.backgroundColor = .clear
//                return cell
//            }
//        }
//    
//    private func configureButtonCell(
//        _ cell: ButtonCell,
//        at indexPath: IndexPath) {
//            cell.layer.masksToBounds = true
//            cell.layer.cornerRadius = 15
//            cell.backgroundColor = .ypWhiteGray
//            
//            if indexPath.row == 0 {
//                cell.layer.maskedCorners = [
//                    .layerMinXMinYCorner,
//                    .layerMaxXMinYCorner
//                ]
//            } else {
//                cell.layer.maskedCorners = [
//                    .layerMinXMaxYCorner,
//                    .layerMaxXMaxYCorner
//                ]
//            }
//            cell.accessoryType = .disclosureIndicator
//            
//            if #available(iOS 14.0, *) {
//                var content = cell.defaultContentConfiguration()
//                content.text = indexPath.row == 0 ? "Категория" : "Расписание"
//                content.secondaryText = indexPath.row == 0 ? categorySubtitle : ""
//                cell.contentConfiguration = content
//            } else {
//                cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
//                cell.detailTextLabel?.text = indexPath.row == 0 ? categorySubtitle : ""
//            }
//            
//            if indexPath.row == 0 {
//                let separator = UIView(frame: CGRect(
//                    x: 20,
//                    y: cell.frame.height - 1,
//                    width: cell.frame.width - 40,
//                    height: 1)
//                )
//                separator.backgroundColor = .lightGray
//                separator.tag = 100
//                cell.addSubview(separator)
//            } else {
//                if let separator = cell.viewWithTag(100) {
//                    separator.removeFromSuperview()
//                }
//            }
//        }
//}
