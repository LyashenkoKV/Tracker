//
//  BaseViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 10.08.2024.
//

import UIKit

class BaseTrackerViewController: UIViewController {
    
    // MARK: - Properties
    var dataProvider: TrackerDataProvider?
    var trackerViewControllerType: TrackerViewControllerType?
    private var isFooterVisible = false
    var emojies: [String] = []
    var colors: [String] = []
    var categories: [TrackerCategory] = []
    var selectedCategories: [TrackerCategory] = []
    var selectedCategory: TrackerCategory?
    var selectedDays: [DayOfTheWeek] = []
    var editingCategoryIndex: IndexPath?
    var trackerToEdit: Tracker?
    
    var sections: [TrackerSection] = [
        .textView,
        .buttons,
        .emoji,
        .color,
        .createButtons
    ]
    
    var isAddingCategory: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - UI Elements
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseIdentifier)
        tableView.register(EmojiesAndColorsTableViewCell.self, forCellReuseIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier)
        tableView.register(CreateButtonsViewCell.self, forCellReuseIdentifier: CreateButtonsViewCell.reuseIdentifier)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.backgroundColor = .ypBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    // MARK: - Initializers
    init(type: TrackerViewControllerType) {
        self.trackerViewControllerType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupLayout()
        configureData()
    }
    
    // MARK: - Configuration Methods
    private func configureUI() {
        view.backgroundColor = .ypBackground
        switch trackerViewControllerType {
        case .typeTrackers:
            self.title = NSLocalizedString(
                "creating_tracker",
                comment: "Создание трекера"
            )
        case .category:
            self.title = NSLocalizedString(
                "category",
                comment: "Категория"
            )
        case .creatingTracker:
            if trackerToEdit != nil {
                self.title = NSLocalizedString(
                    "edit_habit",
                    comment: "Редактирование привычки"
                )
            } else {
                self.title = NSLocalizedString(
                    "new_habit",
                    comment: "Новая привычка"
                )
            }
        case .schedule:
            self.title = NSLocalizedString(
                "schedule",
                comment: "Расписание"
            )
        case .none:
            break
        }
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutConfigurator = LayoutConfiguratorFactory.create(for: trackerViewControllerType)
        layoutConfigurator.setupLayout(in: view, with: tableView)
    }
    
    private func configureData() {
        emojies = EmojiDataProvider.getEmojis()
        colors = ColorDataProvider.getColors()
    }
    
    func updateUI() {}
    
    // Методы выношу из расширения, потому что дочерние классы их не видят
    func textViewCellDidChange(_ cell: TextViewCell) {}
    
    func startEditingCategory(at indexPath: IndexPath) {
        guard let dataProvider = dataProvider, indexPath.row < dataProvider.numberOfItems else {
            print("Ошибка: индекс \(indexPath.row) выходит за пределы источника данных.")
            return
        }

        guard indexPath.row < categories.count else {
            print("Ошибка: индекс \(indexPath.row) выходит за пределы массива категорий.")
            return
        }

        editingCategoryIndex = indexPath
        isAddingCategory = true

        print("Начинаем редактирование категории на индексе \(indexPath.row)")

        tableView.reloadData()
    }
    
    func textViewCellDidEndEditing(_ cell: TextViewCell, text: String?) {
        guard isAddingCategory else { return }
        guard let newText = text, !newText.isEmpty else { return }

        let newCategory = TrackerCategory(title: newText, trackers: [])

        if let editingIndex = editingCategoryIndex {
            // Проверка перед изменением массива
            guard editingIndex.row < categories.count else {
                print("Ошибка: индекс \(editingIndex.row) выходит за пределы массива категорий.")
                return
            }

            categories[editingIndex.row] = newCategory
            editingCategoryIndex = nil
        } else {
            categories.append(newCategory)
        }

        isAddingCategory = false
        tableView.reloadData()
    }
    
    func textViewCellDidBeginEditing(_ cell: TextViewCell) {
        switch trackerViewControllerType {
        case .creatingTracker:
            if trackerToEdit == nil {
                self.title = NSLocalizedString(
                    "creating_habit",
                    comment: "Создание привычки"
                )
            }
        default:
            break
        }
    }
    
    func didSelectCategory(_ category: TrackerCategory) {}
    func didSelect(_ days: [DayOfTheWeek]) {}
    func deleteCategory(at indexPath: IndexPath) {}
    
    func dismissOrCancel() {
        isAddingCategory = false
        dismiss(animated: true)
    }
}

// MARK: - Extensions

// MARK: - ScheduleSelectionDelegate
extension BaseTrackerViewController: ScheduleSelectionDelegate {}
// MARK: - CategorySelectionDelegate
extension BaseTrackerViewController: CategorySelectionDelegate {}

// MARK: - TextViewCellDelegate
extension BaseTrackerViewController: TextViewCellDelegate {
    func textViewCellDidReachLimit(_ cell: TextViewCell) {
        isFooterVisible = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textViewCellDidFallBelowLimit(_ cell: TextViewCell) {
        isFooterVisible = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - UITableViewDataSource
extension BaseTrackerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch trackerViewControllerType {
        case .typeTrackers:
            return 2
        case .creatingTracker:
            return sections.count
        case .category, .schedule:
            return 1
        case .none:
            return 0
        }
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return TableViewHelper.numberOfRows(
                in: trackerViewControllerType,
                section: section,
                dataProvider: dataProvider,
                isAddingCategory: isAddingCategory
            )
        }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return TableViewHelper.cellForRow(
                at: indexPath,
                viewControllerType: trackerViewControllerType,
                tableView: tableView,
                dataProvider: dataProvider,
                isAddingCategory: isAddingCategory,
                selectedCategory: selectedCategory,
                categories: categories,
                editingCategoryIndex: editingCategoryIndex, 
                viewController: self
            )
        }
}

// MARK: - UITableViewDelegate
extension BaseTrackerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        return TableViewHelper.didSelectRow(
            at: indexPath,
            viewControllerType: trackerViewControllerType,
            viewController: self
        )
    }
    
    func handleTypeTrackersSelection(at indexPath: IndexPath) {
        HandleActionsHelper.handleTypeTrackersSelection(at: indexPath, viewController: self)
    }
    
    func handleCreatingTrackerSelection(at indexPath: IndexPath) {
        HandleActionsHelper.handleCreatingTrackerSelection(at: indexPath, viewController: self)
    }
    
    func handleCategorySelection(at indexPath: IndexPath) {
        HandleActionsHelper.handleCategorySelection(at: indexPath, viewController: self)
    }
    
    // Контекстное меню для редактирования категории
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint) -> UIContextMenuConfiguration? {
            
            return ContextMenuHelper.contextMenuConfiguration(
                at: indexPath,
                viewControllerType: trackerViewControllerType,
                dataProvider: dataProvider,
                tableView: tableView,
                viewController: self
            )
        }
    
    // MARK: - Header
    // Настройка хедера
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
            let trackerSection = sections[section]
            
            switch trackerViewControllerType {
            case .creatingTracker:
                return trackerSection.headerTitle
            default:
                break
            }
            return ""
        }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
            let trackerSection = sections[section]
            
            switch trackerSection {
            default:
                if let headerTitle = trackerSection.headerTitle {
                    return ConfigureTableViewCellsHelper.configureTextHeaderView(title: headerTitle)
                }
            }
            return nil
        }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int) -> CGFloat {
            let trackerSection = sections[section]
            
            switch trackerViewControllerType {
            case .creatingTracker:
                switch trackerSection {
                case .textView:
                    return trackerToEdit != nil ? 100 : 35
                case .color, .emoji:
                    return 35
                case .buttons:
                    return 24
                case .createButtons:
                    return 16
                }
            case .schedule:
                return 16
            case .typeTrackers, .category:
                return 0
            case .none:
                return 0
            }
        }
    // MARK: - Footer
    // Настройка футера
    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int) -> UIView? {
            
            let trackerSection = sections[section]
            guard let footerTitle = trackerSection.footerTitle else {
                return nil
            }
            
            let footerView = UIView()
            footerView.backgroundColor = .clear
            
            let footerLabel = UILabel()
            footerLabel.translatesAutoresizingMaskIntoConstraints = false
            footerLabel.text = footerTitle
            footerLabel.textColor = .ypRed
            footerLabel.font = UIFont.systemFont(
                ofSize: 17,
                weight: .regular
            )
            footerLabel.textAlignment = .center
            
            footerView.addSubview(footerLabel)
            
            NSLayoutConstraint.activate([
                footerLabel.leadingAnchor.constraint(
                    equalTo: footerView.leadingAnchor,
                    constant: 16),
                footerLabel.trailingAnchor.constraint(
                    equalTo: footerView.trailingAnchor,
                    constant: -16),
                footerLabel.topAnchor.constraint(
                    equalTo: footerView.topAnchor),
                footerLabel.bottomAnchor.constraint(
                    equalTo: footerView.bottomAnchor)
            ])
            
            switch trackerViewControllerType {
            case .creatingTracker:
                footerLabel.text = trackerSection.footerTitle
            case .typeTrackers, .category, .schedule:
                return nil
            case .none:
                return nil
            }
            return footerView
        }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        let trackerSection = sections[section]
        
        switch trackerViewControllerType {
        case .typeTrackers:
            return 16
        case .creatingTracker:
            switch trackerSection {
            case .textView:
                return isFooterVisible ? 50 : 0
            default:
                return 16
            }
        case .category, .schedule:
            return 0
        case .none:
            return 0
        }
    }
    
    // MARK: - heightForRowAt
    // Настройка высоты ячеек в зависимости от секции и VC
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            switch trackerViewControllerType {
            case .creatingTracker:
                switch indexPath.section {
                case TrackerSection.textView.rawValue:
                    return UITableView.automaticDimension
                case TrackerSection.buttons.rawValue:
                    return 75
                case TrackerSection.emoji.rawValue:
                    return TableViewHelper.calculateCellHeight(
                        for: tableView,
                        itemCount: emojies.count,
                        itemsPerRow: 6
                    )
                case TrackerSection.color.rawValue:
                    return TableViewHelper.calculateCellHeight(
                        for: tableView,
                        itemCount: colors.count,
                        itemsPerRow: 6
                    )
                case TrackerSection.createButtons.rawValue:
                    return UITableView.automaticDimension
                default:
                    return UITableView.automaticDimension
                }
                
            case .typeTrackers:
                return 60
            case .category, .schedule:
                return UITableView.automaticDimension
            case .none:
                return UITableView.automaticDimension
            }
        }
}
