//
//  BaseViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 10.08.2024.
//

import UIKit

class BaseTrackerViewController: UIViewController {
    // MARK: - Properties
    var viewControllerType: TrackerViewControllerType?
    private var isFooterVisible = false
    var emojies: [String] = []
    var colors: [String] = []

    var categories: [String] = []
    private var selectedCategories: [String] = []
    private var selectedDays = ""
    private var selectedCategory = ""
    
    var editingCategoryIndex: IndexPath?
    
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
        tableView.register(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseIdentifier)
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.backgroundColor = .ypWhite
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    // MARK: - Initializers
    init(type: TrackerViewControllerType) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllerType = type
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
        view.backgroundColor = .ypWhite
        switch viewControllerType {
        case .typeTrackers:
            self.title = "Создание трекера"
        case .category:
            self.title = "Категория"
        case .creatingTracker:
            self.title = "Новая привычка"
        case .schedule:
            self.title = "Расписание"
        case .none:
            break
        }
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        func baseTableview() {
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            ])
        }
        
        switch viewControllerType {
        case .typeTrackers:
            let numberOfCells = 2
            let cellHeight: CGFloat = 60
            let spacing: CGFloat = 16
            let tableHeight = CGFloat(numberOfCells) * cellHeight + CGFloat(numberOfCells - 1) * spacing
            
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
                tableView.heightAnchor.constraint(equalToConstant: tableHeight)
            ])
        case .category:
            baseTableview()
        case .creatingTracker:
            baseTableview()
        case .schedule:
            baseTableview()
        case nil:
            break
        }
    }
    
    private func configureData() {
        emojies = [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱",
            "😇", "😡", "🥶", "🤔", "🙌", "🍔",
            "🥦", "🏓", "🥇", "🎸", "🌴", "😪"
        ]
        
        colors = [
            "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
            "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
            "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
        ]
    }
    
    func saveCategoriesToUserDefaults() {
        UserDefaults.standard.set(categories, forKey: "savedCategories")
    }
    
    func loadCategoriesFromUserDefaults() {
        if let savedCategories = UserDefaults.standard.array(forKey: "savedCategories") as? [String] {
            categories = savedCategories
        } else {
            categories = []
        }
    }
    
    func updateUI() {}
    
    // Методы выношу из расширения, потому что дочерние классы их не видят
    func textViewCellDidChange(_ cell: TextViewCell) {}
    
    func startEditingCategory(at indexPath: IndexPath) {
        print("Начато редактирование категории на позиции \(indexPath.row)")
        editingCategoryIndex = indexPath
        isAddingCategory = true
        tableView.reloadData()
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        categories.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        saveCategoriesToUserDefaults()
    }
}

// MARK: - ScheduleSelectionDelegate
extension BaseTrackerViewController: ScheduleSelectionDelegate {
    func didSelect(_ days: String) {
        selectedDays = days

        tableView.reloadRows(
            at: [IndexPath(
                row: 1,
                section: TrackerSection.buttons.rawValue)],
            with: .automatic)
    }
}

// MARK: - CategorySelectionDelegate
extension BaseTrackerViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        tableView.reloadRows(
            at: [IndexPath(
                row: 0,
                section: TrackerSection.buttons.rawValue)],
            with: .automatic)
    }
}

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
    
    func textViewCellDidBeginEditing(_ cell: TextViewCell) {
        switch viewControllerType {
        case .creatingTracker:
            self.title = "Создание привычки"
        default:
            break
        }
    }
    
    // ‼️ Не нравится мне как работает редактирование, сепаратор скачет, надо поправить
    func textViewCellDidEndEditing(_ cell: TextViewCell, text: String?) {
        guard let newText = text, !newText.isEmpty else {
            print("Текст пуст или nil, редактирование не выполнено")
            return
        }
        
        if let editingIndex = editingCategoryIndex {
            categories[editingIndex.row] = newText
            editingCategoryIndex = nil
        } else {
            categories.append(newText)
        }
        saveCategoriesToUserDefaults()
        isAddingCategory = false

        tableView.reloadData()
    }
}


// MARK: - UITableViewDataSource
extension BaseTrackerViewController: UITableViewDataSource {
    // Устанавливаю количесво секций в каждом VC
    func numberOfSections(in tableView: UITableView) -> Int {
        switch viewControllerType {
        case .typeTrackers:
            return 2
        case .creatingTracker:
            return TrackerSection.allCases.count
        case .category:
            return 1
        case .schedule:
            return 1
        case .none:
            return 0
        }
    }
    // Устанавливаю количесво ячеек в каждой секции VC
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            switch viewControllerType {
            case .typeTrackers:
                return 1
            case .creatingTracker:
                guard let trackerSection = TrackerSection(rawValue: section) else {
                    return 0
                }
                switch trackerSection {
                case .textView:
                    return 1
                case .buttons:
                    return 2
                case .emoji, .color, .createButtons:
                    return 1
                }
            case .category:
                return isAddingCategory ? 1 : categories.count
            case .schedule:
                return DayOfTheWeek.allCases.count
            case .none:
                return 0
            }
        }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            switch viewControllerType {
            case .typeTrackers:
                return configureTypeTrackersCell(at: indexPath)
            case .creatingTracker, .schedule:
                return UITableViewCell()
            case .category:
                if isAddingCategory {
                    return configureTextViewCell(at: indexPath)
                } else {
                    return configureCategoryCell(at: indexPath)
                }
            case .none:
                return UITableViewCell()
            }
        }
    
    private func configureTypeTrackersCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.section == 0 {
            cell.textLabel?.text = "Привычка"
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "Нерегулярное событие"
        }
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .ypBlack
        cell.textLabel?.textColor = .ypWhite
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        cell.selectionStyle = .none
        return cell
    }
    
    private func configureCategoryCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        cell.configure(with: categories[indexPath.row])
        configureBaseCell(cell, at: indexPath, totalRows: categories.count)
        configureSeparator(cell, isLastRow: indexPath.row == categories.count - 1)
        return cell
    }
    
    private func configureTextViewCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TextViewCell.reuseIdentifier,
            for: indexPath
        ) as? TextViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        if let editingIndex = editingCategoryIndex, editingIndex.row == indexPath.row {
            cell.getText().text = categories[editingIndex.row]
            self.title = "Редактирование категории"
        } else {
            cell.getText().text = ""
            self.title = "Новая категория"
        }
        
        configureBaseCell(cell, at: indexPath, totalRows: 1)
        configureSeparator(cell, isLastRow: true)
        
        return cell
    }
    
    
    // Конфигурация ячеек ButtonCell, с настройкой скругления Top первой ячейки и Bottom второй
    func configureButtonCell(
        _ cell: UITableViewCell,
        at indexPath: IndexPath) {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 15
            cell.backgroundColor = .ypWhiteGray
            cell.heightAnchor.constraint(equalToConstant: 75).isActive = true
            
            if indexPath.row == 0 {
                cell.layer.maskedCorners = [
                    .layerMinXMinYCorner,
                    .layerMaxXMinYCorner
                ]
            } else {
                cell.layer.maskedCorners = [
                    .layerMinXMaxYCorner,
                    .layerMaxXMaxYCorner
                ]
            }
            cell.accessoryType = .disclosureIndicator
            
            if #available(iOS 14.0, *) {
                var content = cell.defaultContentConfiguration()
                content.text = indexPath.row == 0 ? "Категория" : "Расписание"
                content.secondaryText = indexPath.row == 0 && !isAddingCategory ? selectedCategory : selectedDays
                cell.contentConfiguration = content
            } else {
                cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
                cell.detailTextLabel?.text = indexPath.row == 0 && !isAddingCategory ? selectedCategory : selectedDays
            }
        }
    
    // Конфигурация ячеек наследуемых от BaseCell, с настройкой скругления Top первой ячейки и Bottom последней
    func configureBaseCell(
        _ cell: UITableViewCell,
        at indexPath: IndexPath,
        totalRows: Int) {
            
            cell.layer.masksToBounds = true
            cell.backgroundColor = .ypWhiteGray
            cell.selectionStyle = .none
            cell.tintColor = .systemBlue
            
            if totalRows == 1 {
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [
                    .layerMinXMinYCorner,
                    .layerMaxXMinYCorner,
                    .layerMinXMaxYCorner,
                    .layerMaxXMaxYCorner
                ]
            } else if indexPath.row == 0 {
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [
                    .layerMinXMinYCorner,
                    .layerMaxXMinYCorner
                ]
            } else if indexPath.row == totalRows - 1 {
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [
                    .layerMinXMaxYCorner,
                    .layerMaxXMaxYCorner
                ]
            } else {
                cell.layer.cornerRadius = 0
            }
        }
    
    // Настройка сепаратора (для визуального разделения ячеек)
    func configureSeparator(_ cell: UITableViewCell, isLastRow: Bool) {
        cell.contentView.subviews.filter { $0.tag == 1001 }.forEach { $0.removeFromSuperview() }
        
        guard !isLastRow else { return }
        
        let separator = UIView()
        separator.tag = 1001
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            separator.widthAnchor.constraint(equalToConstant: cell.frame.width),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate
extension BaseTrackerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        switch viewControllerType {
        case .typeTrackers:
            handleTypeTrackersSelection(at: indexPath)
        case .creatingTracker:
            handleCreatingTrackerSelection(at: indexPath)
        case .category:
            handleCategorySelection(at: indexPath)
        case .schedule:
            break
        case .none:
            break
        }
    }
    
    private func handleTypeTrackersSelection(at indexPath: IndexPath) {
        if indexPath.section == 0 {
            let creatingTrackerVC = CreatingTrackerViewController(type: .creatingTracker)
//            if let delegate = self as? CreatingTrackerDelegate {
//                creatingTrackerVC.delegate = delegate
//            }
            
            let navController = UINavigationController(rootViewController: creatingTrackerVC)
            navController.modalPresentationStyle = .formSheet
            self.present(navController, animated: true)
        } else if indexPath.section == 1 {
            let irregularEventVC = CreatingTrackerViewController(type: .creatingTracker)
            irregularEventVC.title = "Нерегулярное событие"
            let navController = UINavigationController(rootViewController: irregularEventVC)
            navController.modalPresentationStyle = .formSheet
            self.present(navController, animated: true)
        }
    }
    
    private func handleCreatingTrackerSelection(at indexPath: IndexPath) {
        if indexPath.section == TrackerSection.buttons.rawValue {
            if indexPath.row == 0 {
                let categoryVC = CategoryViewController(type: .category)
                categoryVC.delegate = self
                let navController = UINavigationController(rootViewController: categoryVC)
                navController.modalPresentationStyle = .formSheet
                self.present(navController, animated: true)
            } else if indexPath.row == 1 {
                let scheduleVC = ScheduleViewController(type: .schedule)
                scheduleVC.delegate = self
                let navController = UINavigationController(rootViewController: scheduleVC)
                navController.modalPresentationStyle = .formSheet
                self.present(navController, animated: true)
            } else {
                print("Неизвестный индекс ячейки: \(indexPath.row)")
            }
        }
    }
    
    private func handleCategorySelection(at indexPath: IndexPath) {
        if !isAddingCategory {
            let selectedCategory = categories[indexPath.row]
            selectedCategories.append(selectedCategory)
        }
    }
    
    // Контекстное меню для редактирования категории
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint) -> UIContextMenuConfiguration? {
            
            switch viewControllerType {
            case .category:
                guard indexPath.row < categories.count else {
                    return nil
                }
                
                return UIContextMenuConfiguration(actionProvider:  { [weak self] _ in
                    let editAction = UIAction(title: "Редактировать") { _ in
                        self?.startEditingCategory(at: indexPath)
                    }
                    
                    let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                        self?.deleteCategory(at: indexPath)
                    }
                    
                    return UIMenu(title: "", children: [editAction, deleteAction])
                })
                
            default:
                return nil
            }
        }
    
    // MARK: - Header
    // Настройка хедера
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
            guard let trackerSection = TrackerSection(rawValue: section) else {
                return nil
            }
            
            switch viewControllerType {
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
            guard let trackerSection = TrackerSection(rawValue: section) else {
                return nil
            }
            
            let headerView = UIView()
            headerView.backgroundColor = .clear
            
            let headerLabel = UILabel()
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.textColor = .ypBlack
            headerLabel.font = UIFont.boldSystemFont(ofSize: 19)
            headerView.addSubview(headerLabel)
            
            NSLayoutConstraint.activate([
                headerLabel.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor,
                    constant: 16),
                headerLabel.trailingAnchor.constraint(
                    equalTo: headerView.trailingAnchor,
                    constant: -16),
                headerLabel.topAnchor.constraint(
                    equalTo: headerView.topAnchor),
                headerLabel.bottomAnchor.constraint(
                    equalTo: headerView.bottomAnchor)
            ])
            
            switch viewControllerType {
            case .creatingTracker:
                headerLabel.text = trackerSection.headerTitle
            default:
                break
            }
            return headerView
        }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int) -> CGFloat {
            guard let trackerSection = TrackerSection(rawValue: section) else {
                return 0
            }
            
            switch viewControllerType {
            case .creatingTracker:
                switch trackerSection {
                case .textView, .color, .emoji:
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
            
            switch viewControllerType {
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
        guard let trackerSection = TrackerSection(rawValue: section) else { return 0 }
        
        switch viewControllerType {
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
            switch viewControllerType {
            case .creatingTracker:
                switch indexPath.section {
                case TrackerSection.textView.rawValue:
                    return UITableView.automaticDimension
                case TrackerSection.buttons.rawValue:
                    return 75
                case TrackerSection.emoji.rawValue, TrackerSection.color.rawValue:
                    return 180
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
