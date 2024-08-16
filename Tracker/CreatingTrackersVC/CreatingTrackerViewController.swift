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
    private var isRegularEvent: Bool

    init(type: TrackerViewControllerType, isRegularEvent: Bool) {
        self.isRegularEvent = isRegularEvent
        super.init(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
        dismissKeyboard(view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCreateButtonState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateCreateButtonState() {
        guard let textViewCell = tableView.cellForRow(
            at: IndexPath(row: 0, section: TrackerSection.textView.rawValue)
        ) as? TextViewCell else { return }
        
        let textIsValid = !textViewCell.getText().text.isEmpty
        let categoryIsSelected = selectedCategory != nil
        let colorIsSelected = selectedColor != nil
        let emojiIsSelected = selectedEmoji != nil
        let daysAreSelected = !(selectedDays?.days.isEmpty ?? true)

        let isValid: Bool

        if isRegularEvent {
            isValid = textIsValid && daysAreSelected && categoryIsSelected && colorIsSelected && emojiIsSelected
        } else {
            isValid = textIsValid && categoryIsSelected && colorIsSelected && emojiIsSelected
        }
        
        if let createButtonCell = tableView.cellForRow(
            at: IndexPath(row: 0, section: TrackerSection.createButtons.rawValue)
        ) as? CreateButtonsViewCell {
            createButtonCell.updateCreateButtonState(isEnabled: isValid)
        }
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
            at: IndexPath(row: 0, section: TrackerSection.textView.rawValue)
        ) as? TextViewCell,
        let trackerName = textViewCell.getText().text, !trackerName.isEmpty,
        let selectedColor = selectedColor,
        let selectedEmoji = selectedEmoji else {
            return
        }
        
        let categoryTitle: String
        
        if let selectedCategory = selectedCategory {
            categoryTitle = selectedCategory.title
        } else {
            categoryTitle = "Новая категория"
        }

        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedDays ?? Schedule(days: []),
            categoryTitle: categoryTitle,
            isRegularEvent: isRegularEvent,
            creationDate: Date()
        )

        let userInfo: [String: Any] = [
            "tracker": tracker,
            "categoryTitle": categoryTitle
        ]
        
        clearSavedData()
        
        NotificationCenter.default.post(name: .trackerCreated, object: nil, userInfo: userInfo)
        
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }

    private func handleCancelButtonTapped() {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func handleEmojiSelected(_ notification: Notification) {
        if let emoji = notification.userInfo?["selectedEmoji"] as? String {
            selectedEmoji = emoji
            updateCreateButtonState()
        }
    }
    
    @objc private func handleColorSelected(_ notification: Notification) {
        if let hexColor = notification.userInfo?["selectedColor"] as? String {
            selectedColor = UIColor(hex: hexColor)
            updateCreateButtonState()
        }
    }
}

extension CreatingTrackerViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let trackerSection = TrackerSection(rawValue: section) else { return 0 }
        switch trackerSection {
        case .textView:
            return 1
        case .buttons:
            return isRegularEvent ? 2 : 1
        case .emoji, .color, .createButtons:
            return 1
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
            if !isRegularEvent && indexPath.row == 1 {
                return UITableViewCell()
            }
            let cell = UITableViewCell()
            
            let totalRows = isRegularEvent ? 2 : 1
            
            configureButtonCell(cell, at: indexPath, isSingleCell: isRegularEvent)
            configureBaseCell(cell, at: indexPath, totalRows: totalRows)
            configureSeparator(cell, isLastRow: indexPath.row == (isRegularEvent ? 1 : 0))
            cell.selectionStyle = .none
            return cell
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
