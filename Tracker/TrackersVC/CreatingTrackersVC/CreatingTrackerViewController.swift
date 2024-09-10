//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

final class CreatingTrackerViewController: BaseTrackerViewController {
    
    private var trackerName: String?
    var selectedColor: UIColor?
    var selectedEmoji: String?
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
    
    override func textViewCellDidChange(_ cell: TextViewCell) {
        updateCreateButtonState()
    }
    
    override func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    override func didSelect(_ days: [DayOfTheWeek]) {
        self.selectedDays = days
        updateCreateButtonState()
        tableView.reloadRows(
            at: [IndexPath(row: 1, section: TrackerSection.buttons.rawValue)],
            with: .automatic
        )
    }
    
    func updateCreateButtonState() {
        guard let textViewCell = tableView.cellForRow(
            at: IndexPath(row: 0, section: TrackerSection.textView.rawValue)
        ) as? TextViewCell else { return }
        
        let textIsValid = !textViewCell.isPlaceholderActive() && !textViewCell.getText().text.isEmpty
        let categoryIsSelected = selectedCategory != nil
        let colorIsSelected = selectedColor != nil
        let emojiIsSelected = selectedEmoji != nil && !(selectedEmoji?.isEmpty ?? true)
        let daysAreSelected = !selectedDays.isEmpty
        
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
        guard let textViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: TrackerSection.textView.rawValue)) as? TextViewCell,
              let trackerName = textViewCell.getText().text, !trackerName.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else {
            Logger.shared.log(
                .error,
                message: "Не все обязательные поля заполнены для создания трекера"
            )
            return
        }
        
        let categoryTitle = selectedCategory?.title ?? "Новая категория"
        let scheduleStrings = selectedDays.map { String($0.rawValue) }

        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor.toHexString(),
            emoji: selectedEmoji,
            schedule: scheduleStrings,
            categoryTitle: categoryTitle,
            isRegularEvent: isRegularEvent,
            creationDate: Date()
        )
        
        let userInfo: [String: Any] = [
            "tracker": tracker,
            "categoryTitle": categoryTitle
        ]
        
        NotificationCenter.default.post(name: .trackerCreated, object: nil, userInfo: userInfo)
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }

    private func handleCancelButtonTapped() {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func handleEmojiSelected(_ notification: Notification) {
        HandleActionsHelper.handleEmojiSelected(notification: notification, viewController: self)
    }
    
    @objc private func handleColorSelected(_ notification: Notification) {
        HandleActionsHelper.handleColorSelected(notification: notification, viewController: self)
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
               return ConfigureTableViewCellsHelper.configureTextViewCell(for: tableView, at: indexPath, delegate: self)
           case .buttons:
               let cell = UITableViewCell()
               let totalRows = isRegularEvent ? 2 : 1
               ConfigureTableViewCellsHelper.configureButtonCell(
                cell, at: indexPath,
                isSingleCell: isRegularEvent,
                isAddingCategory: isAddingCategory,
                selectedCategory: selectedCategory,
                selectedDaysString: selectedDaysString()
               )
               ConfigureTableViewCellsHelper.configureBaseCell(
                cell,
                at: indexPath,
                totalRows: totalRows
               )
               ConfigureTableViewCellsHelper.configureSeparator(
                cell,
                isLastRow: indexPath.row == (isRegularEvent ? 1 : 0)
               )
               cell.selectionStyle = .none
               return cell
           case .emoji:
               return ConfigureTableViewCellsHelper.configureEmojiAndColorCell(
                for: tableView,
                at: indexPath,
                with: emojies,
                isEmoji: true
               )
           case .color:
               return ConfigureTableViewCellsHelper.configureEmojiAndColorCell(
                for: tableView,
                at: indexPath,
                with: colors,
                isEmoji: false
               )
           case .createButtons:
               return ConfigureTableViewCellsHelper.configureCreateButtonsCell(
                   for: tableView,
                   at: indexPath,
                   onCreateTapped: { [weak self] in self?.handleCreateButtonTapped() },
                   onCancelTapped: { [weak self] in self?.handleCancelButtonTapped() }
               )
           }
       }
    
    private func selectedDaysString() -> String {
        if selectedDays.isEmpty {
            return ""
        }
        
        let daysOrder: [DayOfTheWeek] = [
            .monday, .tuesday, .wednesday,
            .thursday, .friday, .saturday,
            .sunday
        ]
        
        let fullWeek = Set(daysOrder)
        let selectedSet = Set(selectedDays)
        
        if selectedSet == fullWeek {
            return "Каждый день"
        }
        
        let sortedDays = selectedDays.sorted {
            daysOrder.firstIndex(of: $0) ?? 0 < daysOrder.firstIndex(of: $1) ?? 0
        }
        
        let dayShortcuts = sortedDays.map { day in
            switch day {
            case .monday: return "Пн"
            case .tuesday: return "Вт"
            case .wednesday: return "Ср"
            case .thursday: return "Чт"
            case .friday: return "Пт"
            case .saturday: return "Сб"
            case .sunday: return "Вс"
            }
        }
        
        return dayShortcuts.joined(separator: ", ")
    }
}
