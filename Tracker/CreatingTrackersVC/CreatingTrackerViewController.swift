//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

protocol CreatingTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in category: String)
}

final class CreatingTrackerViewController: BaseTrackerViewController {

    weak var delegate: CreatingTrackerDelegate?

    private var trackerName: String?
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    private var selectedSchedule: Schedule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewControllerType {
        case .creatingTracker:
            return configureCreatingTrackerCell(at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
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
                print("handleCreateButtonTapped")
            }
            
            cell.onCancelButtonTapped = { [weak self] in
                self?.handleCancelButtonTapped()
                print("handleCancelButtonTapped")
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    private func handleCreateButtonTapped() {
        guard let trackerName = trackerName,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji,
              let selectedSchedule = selectedSchedule else {
            return // Возвращаемся, если необходимые данные не заполнены
        }

        let tracker = Tracker.tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )

        delegate?.didCreateTracker(tracker, in: "Здоровье") // Здесь можно передать выбранную категорию
        dismiss(animated: true)
    }

    private func handleCancelButtonTapped() {
        dismiss(animated: true)
    }
}
