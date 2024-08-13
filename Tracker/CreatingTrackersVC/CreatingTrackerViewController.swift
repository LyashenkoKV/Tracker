//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

final class CreatingTrackerViewController: BaseTrackerViewController {
    
    private var trackerName: String?
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    private var selectedSchedule: Schedule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEmojiSelected),
            name: .emojiSelected,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleColorSelected),
            name: .colorSelected,
            object: nil)
    }
    
    func handleCreateButtonTapped() {
        guard let textViewCell = tableView.cellForRow(
            at: IndexPath(
                row: 0,
                section: TrackerSection.textView.rawValue)
        ) as? TextViewCell,
              let trackerName = textViewCell.getText().text, !trackerName.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else {
            return
        }

        let tracker = Tracker.tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule ?? .dayOfTheWeek([])
        )

        let categoryTitle: String
        if let selectedCategory = selectedCategory,
           case let .category(title, _) = selectedCategory {
            categoryTitle = title
        } else {
            categoryTitle = "Новая категория"
        }

        let userInfo: [String: Any] = ["tracker": tracker, "categoryTitle": categoryTitle]
        NotificationCenter.default.post(name: .trackerCreated, object: nil, userInfo: userInfo)
        
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }

    private func handleCancelButtonTapped() {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func handleEmojiSelected(_ notification: Notification) {
        if let emoji = notification.userInfo?["selectedEmoji"] as? String {
            selectedEmoji = emoji
        }
    }
    
    @objc private func handleColorSelected(_ notification: Notification) {
        if let hexColor = notification.userInfo?["selectedColor"] as? String {
            selectedColor = UIColor(hex: hexColor)
        }
    }
}

// MARK: - cellForRowAt
extension CreatingTrackerViewController {
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewControllerType {
        case .creatingTracker:
            return configureCreatingTrackerCell(at: indexPath)
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - ConfigureCell
extension CreatingTrackerViewController {
    private func configureCreatingTrackerCell(at indexPath: IndexPath) -> UITableViewCell {
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
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        case .buttons:
            if indexPath.section == TrackerSection.buttons.rawValue {
                let cell = UITableViewCell()
                configureButtonCell(cell, at: indexPath)
                configureSeparator(cell, isLastRow: indexPath.row == 1)
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()
        case .emoji:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiesAndColorsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: emojies, isEmoji: true)
            cell.selectionStyle = .none
            return cell
        case .color:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiesAndColorsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: colors, isEmoji: false)
            cell.selectionStyle = .none
            return cell
        case .createButtons:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CreateButtonsViewCell.reuseIdentifier,
                for: indexPath
            ) as? CreateButtonsViewCell else {
                return UITableViewCell()
            }
            
            cell.onCreateButtonTapped = { [weak self] in
                self?.handleCreateButtonTapped()
            }
            
            cell.onCancelButtonTapped = { [weak self] in
                self?.handleCancelButtonTapped()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
