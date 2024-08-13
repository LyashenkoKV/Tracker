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
        
        guard let textViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: TrackerSection.textView.rawValue)) as? TextViewCell,
              let trackerName = textViewCell.getText().text, !trackerName.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else {
            print("Условия не выполнены: \(trackerName), \(selectedColor), \(selectedEmoji)")
            return
        }
        
        print("Треккер - \(trackerName)")
        
        let tracker = Tracker.tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule ?? .dayOfTheWeek(["Понедельник", "Среда"])
        )
        
        if let selectedCategory = selectedCategory,
           let categoryIndex = categories.firstIndex(where: {
            if case let .category(title, _) = $0 {
                return title == {
                    if case let .category(categoryTitle, _) = selectedCategory {
                        return categoryTitle
                    } else {
                        return ""
                    }
                }()
            }
            return false
        }) {
            if case let .category(title, trackers) = categories[categoryIndex] {
                var updatedTrackers = trackers
                updatedTrackers.append(tracker)
                categories[categoryIndex] = .category(title: title, trackers: updatedTrackers)
            }
        } else {
            if case let .category(title, _) = selectedCategory {
                let newCategory = TrackerCategory.category(title: title, trackers: [tracker])
                categories.append(newCategory)
            }
        }
 
        NotificationCenter.default.post(name: .trackerCreated, object: nil)
        
        print("Категория - \(categories)")
        
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
//    private func handleCreateButtonTapped() {
//            
//            guard let textViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: TrackerSection.textView.rawValue)) as? TextViewCell,
//                  let trackerName = textViewCell.getText().text, !trackerName.isEmpty else {
//                print("Название трекера не может быть пустым")
//                return
//            }
//            
//    //        guard !selectedCategory.isEmpty else {
//    //            print("Не выбрана категория")
//    //            return
//    //        }
//            
//            let schedule = Schedule.dayOfTheWeek(["Понедельник", "Среда"])
//            
//            guard let selectedColor = selectedColor else {
//                print("Не выбран цвет")
//                return
//            }
//            
//            guard let selectedEmoji = selectedEmoji, !selectedEmoji.isEmpty else {
//                print("Не выбран emoji")
//                return
//            }
//
//            let tracker = Tracker.tracker(
//                id: UUID(),
//                name: trackerName,
//                color: selectedColor,
//                emoji: selectedEmoji,
//                schedule: schedule
//            )
//            
//            let userInfo: [String: Any] = ["tracker": tracker, "categoryTitle": "Спорт"]
//            
//            NotificationCenter.default.post(name: .trackerCreated, object: nil, userInfo: userInfo)
//            
//            presentingViewController?.presentingViewController?.dismiss(animated: true)
//        }

    private func handleCancelButtonTapped() {
        print("handleCancelButtonTapped")
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
