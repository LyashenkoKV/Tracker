//
//  CreatingTrackerViewController + Extennsions Delegate.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

extension CreatingTrackerViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let trackerSection = TrackerSection(rawValue: indexPath.section) else {
                return UITableView.automaticDimension
            }
            
            switch trackerSection {
            case .textView:
                return UITableView.automaticDimension
            case .buttons:
                return 75
            case .emoji, .color:
                return 180
            case .createButtons:
                return UITableView.automaticDimension
            }
        }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
            guard let trackerSection = TrackerSection(rawValue: section) else {
                return nil
            }
            return trackerSection.headerTitle
        }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
            guard let trackerSection = TrackerSection(rawValue: section),
                  let headerTitle = trackerSection.headerTitle else {
                return nil
            }
            
            let headerView = UIView()
            headerView.backgroundColor = .clear
            
            let headerLabel = UILabel()
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.text = headerTitle
            headerLabel.textColor = .ypBlack
            headerLabel.font = UIFont.boldSystemFont(ofSize: 19)
            
            headerView.addSubview(headerLabel)
            
            NSLayoutConstraint.activate([
                headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int) -> CGFloat {
            guard let trackerSection = TrackerSection(rawValue: section),
                  trackerSection.headerTitle != nil else {
                return 0
            }
            return 44
        }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let trackerSection = TrackerSection(rawValue: section),
              let footerTitle = trackerSection.footerTitle else {
            return nil
        }
        
        let footerView = UIView()
        footerView.backgroundColor = .clear
        
        let footerLabel = UILabel()
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.text = footerTitle
        footerLabel.textColor = .ypRed
        footerLabel.font = UIFont.systemFont(ofSize: 17)
        footerLabel.textAlignment = .center
        
        footerView.addSubview(footerLabel)
        
        NSLayoutConstraint.activate([
            footerLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            footerLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            footerLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 8),
            footerLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -8)
        ])
        
        return footerView
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let categoryVC = CategoryViewController()
            let navController = UINavigationController(rootViewController: categoryVC)
            navController.modalPresentationStyle = .formSheet
            self.present(navController, animated: true, completion: nil)
        }
    }
}
