//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

final class CreatingTrackerViewController: BaseTrackerViewController {
    
    private var trackerName: String? {
        didSet { validateForm() }
    }
    
    private var isRegularEvent: Bool
    var completedTrackers: Set<TrackerRecord>?
    
    var selectedColor: UIColor? {
        didSet { validateForm() }
    }
    
    var selectedEmoji: String? {
        didSet { validateForm() }
    }
    
    override var selectedDays: [DayOfTheWeek] {
        didSet { validateForm() }
    }
    
    override var selectedCategory: TrackerCategory? {
        didSet { validateForm() }
    }
    
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
        setupTrackerForEditing()
        setupNotificationObservers()
        dismissKeyboard(view: self.view)
        
        if let trackerToEdit = trackerToEdit {
            updateUIForEditing(tracker: trackerToEdit)
            updateCreateButtonTitle()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCreateButtonTitle()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func textViewCellDidChange(_ cell: TextViewCell) {
        self.trackerName = cell.getText().text
    }
    
    override func didSelectCategory(_ category: TrackerCategory) {
        self.selectedCategory = category
        tableView.reloadData()
    }
    
    override func didSelect(_ days: [DayOfTheWeek]) {
        self.selectedDays = days
        tableView.reloadRows(
            at: [IndexPath(row: 1, section: TrackerSection.buttons.rawValue)],
            with: .automatic
        )
    }
    
    private func updateCreateButtonTitle() {
        if let createButtonCell = tableView.cellForRow(
            at: IndexPath(
                row: 0,
                section: TrackerSection.createButtons.rawValue
            )
        ) as? CreateButtonsViewCell {
            let isEditing = trackerToEdit != nil
            createButtonCell.updateCreateButtonTitle(isEditing: isEditing)
        }
    }
    
    private func setupTrackerForEditing() {
        if let tracker = trackerToEdit {
            trackerName = tracker.name
            selectedColor = UIColor(hex: tracker.color)
            selectedEmoji = tracker.emoji
            selectedDays = tracker.schedule.compactMap { DayOfTheWeek(rawValue: $0) }
            selectedCategory = TrackerCategory(title: tracker.categoryTitle, trackers: [])

            tableView.reloadData()
        }
    }

    private func validateForm() {
        let nameIsValid = trackerName != nil && !trackerName!.isEmpty
        let colorIsValid = selectedColor != nil
        let emojiIsValid = selectedEmoji != nil && !selectedEmoji!.isEmpty
        let categoryIsValid = selectedCategory != nil
        let daysAreSelected = !selectedDays.isEmpty
        
        let isValid: Bool
        if isRegularEvent {
            isValid = nameIsValid && colorIsValid && emojiIsValid && categoryIsValid && daysAreSelected
        } else {
            isValid = nameIsValid && colorIsValid && emojiIsValid && categoryIsValid
        }
        
        updateCreateButtonState(isValid: isValid)
    }
    
    private func updateCreateButtonState(isValid: Bool) {
        if let createButtonCell = tableView.cellForRow(
            at: IndexPath(row: 0, section: TrackerSection.createButtons.rawValue)
        ) as? CreateButtonsViewCell {
            createButtonCell.updateCreateButtonState(isEnabled: isValid)
        }
    }
    
    private func calculateDaysCount() -> Int {
        guard let tracker = trackerToEdit, let completedTrackers = completedTrackers else {
            return 0
        }
        
        let count = completedTrackers.filter { $0.trackerId == tracker.id }.count
        return count
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
    
    private func updateUIForEditing(tracker: Tracker) {
        selectedCategory = TrackerCategory(title: tracker.categoryTitle, trackers: [])
        selectedColor = UIColor(hex: tracker.color)
        selectedEmoji = tracker.emoji
        selectedDays = tracker.schedule.compactMap { DayOfTheWeek(rawValue: $0) }
        
        tableView.reloadData()
    }
    
    func handleCreateButtonTapped() {
        if let trackerToEdit = trackerToEdit {
            updateExistingTracker(trackerToEdit)
        } else {
            createNewTracker()
        }
    }
    
    private func updateExistingTracker(_ tracker: Tracker) {
        guard let trackerName = trackerName, !trackerName.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else {
            Logger.shared.log(
                .error,
                message: "Не все обязательные поля заполнены для создания трекера"
            )
            return
        }
        
        let categoryTitle = selectedCategory?.title ?? tracker.categoryTitle
        let scheduleStrings = selectedDays.map { String($0.rawValue) }
        
        let updatedTracker = Tracker(
            id: tracker.id,
            name: trackerName,
            color: selectedColor.toHexString(),
            emoji: selectedEmoji,
            schedule: scheduleStrings,
            categoryTitle: categoryTitle,
            isRegularEvent: tracker.isRegularEvent,
            creationDate: tracker.creationDate,
            isPinned: tracker.isPinned
        )
        
        let userInfo: [String: Any] = [
            "tracker": updatedTracker,
            "categoryTitle": categoryTitle
        ]
        
        NotificationCenter.default.post(name: .trackerUpdated, object: nil, userInfo: userInfo)
        presentingViewController?.dismiss(animated: true)
    }
    
    private func createNewTracker() {
        guard let trackerName = trackerName, !trackerName.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else {
            Logger.shared.log(
                .error,
                message: "Не все обязательные поля заполнены для создания трекера"
            )
            return
        }
        
        let categoryTitle = selectedCategory?.title ?? ""
        let scheduleStrings = selectedDays.map { String($0.rawValue) }
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor.toHexString(),
            emoji: selectedEmoji,
            schedule: scheduleStrings,
            categoryTitle: categoryTitle,
            isRegularEvent: isRegularEvent,
            creationDate: Date(),
            isPinned: false
        )

        let userInfo: [String: Any] = [
            "tracker": newTracker,
            "categoryTitle": categoryTitle
        ]
        
        NotificationCenter.default.post(name: .trackerCreated, object: nil, userInfo: userInfo)
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    private func handleCancelButtonTapped() {
        if trackerToEdit != nil {
            presentingViewController?.dismiss(animated: true)
        } else {
            presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
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
        let trackerSection = sections[section]
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
            switch trackerViewControllerType {
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
        let trackerSection = sections[indexPath.section]
        
        switch trackerSection {
        case .textView:
            return ConfigureTableViewCellsHelper.configureTextViewCell(
                for: tableView,
                at: indexPath,
                delegate: self,
                trackerToEdit: trackerToEdit
            )
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
                isEmoji: true,
                selectedElement: selectedEmoji
            )
        case .color:
            return ConfigureTableViewCellsHelper.configureEmojiAndColorCell(
                for: tableView,
                at: indexPath,
                with: colors,
                isEmoji: false,
                selectedElement: selectedColor?.toHexString()
            )
        case .createButtons:
            return ConfigureTableViewCellsHelper.configureCreateButtonsCell(
                for: tableView,
                at: indexPath,
                onCreateTapped: { [weak self] in self?.handleCreateButtonTapped() },
                onCancelTapped: { [weak self] in self?.handleCancelButtonTapped() }, 
                isEditing: trackerToEdit != nil
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
            return LocalizationKey.everyDay.localized()
        }
        
        let sortedDays = selectedDays.sorted {
            daysOrder.firstIndex(of: $0) ?? 0 < daysOrder.firstIndex(of: $1) ?? 0
        }
        
        let dayShortcuts = sortedDays.map { day in
            switch day {
            case .monday:
                return LocalizationKey.mondayShort.localized()
            case .tuesday:
                return LocalizationKey.tuesdayShort.localized()
            case .wednesday:
                return LocalizationKey.wednesday.localized()
            case .thursday:
                return LocalizationKey.thursdayShort.localized()
            case .friday:
                return LocalizationKey.fridayShort.localized()
            case .saturday:
                return LocalizationKey.saturdayShort.localized()
            case .sunday:
                return LocalizationKey.sundayShort.localized()
            }
        }
        return dayShortcuts.joined(separator: ", ")
    }
}

// MARK: - viewForHeaderInSection
extension CreatingTrackerViewController {
    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
            let trackerSection = sections[section]
            
            switch trackerSection {
            case .textView:
                if trackerToEdit != nil {
                    let daysCount = calculateDaysCount()
                    return ConfigureTableViewCellsHelper.configureCounterHeaderView(with: daysCount)
                }
            case .emoji, .color:
                if let headerTitle = trackerSection.headerTitle {
                    return ConfigureTableViewCellsHelper.configureTextHeaderView(title: headerTitle)
                }
            default:
                return nil
            }
            return nil
        }
}
