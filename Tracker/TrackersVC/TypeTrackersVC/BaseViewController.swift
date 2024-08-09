//
//  BaseViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 09.08.2024.
//

import UIKit

// Подумать как использовать общий VC с перегрузкой ячеек

enum ViewControllers: Int, CaseIterable {
    case typeVC
    case habitVC
    case categoryVC
    case scheduleVC
    
    var titleVC: String? {
        switch self {
        case .typeVC:
            return "Создание трекера"
        case .habitVC:
            return "Новая привычка"
        case .categoryVC:
            return "Категория"
        case .scheduleVC:
            return "Расписание"
        }
    }
}

class BaseViewController: UIViewController {
    
    var isFooterVisible = false

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseIdentifier)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
        tableView.register(EmojiesAndColorsTableViewCell.self, forCellReuseIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier)
        tableView.register(CreateButtonsViewCell.self, forCellReuseIdentifier: CreateButtonsViewCell.reuseIdentifier)
        tableView.backgroundColor = .ypWhite
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    private let categoryButtonTitle = "Добавить категорию"
    
    var emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🌴", "😪"
    ]
    
    var colors = [
        "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
        "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
        "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
    ]
    
    private let buttonTitle = "Добавить категорию"
    private let placeholderText = "Введите название категории"
    
    private var categories: [String] = []
    private var selectedCategories: [String] = []
    
    private var isAddingCategory = false
    
    private lazy var habitButton = addNewButton(
        with: "Привычка",
        action: #selector(createNewTracker)
    )
    private lazy var irregularEventButton = addNewButton(
        with: "Нерегулярное событие",
        action: #selector(createNewTracker)
    )
    private lazy var addCategoryButton = addNewButton(
        with: categoryButtonTitle,
        action: #selector(addCategoryButtonAction)
    )
    
    private lazy var typeTrackersButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
        habitButton,
        irregularEventButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private lazy var categoryStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            tableView,
            addCategoryButton
        ])
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var placeholder: Placeholder = {
        let placeholder = Placeholder(
            image: UIImage(named: "Error"),
            text: "Что будем отслеживать?"
        )
        return placeholder
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        //self.title =
        setupTableViewLayout()
    }

    private func setupTableViewLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupTypeTrackerLayout() {
        [habitButton, irregularEventButton, typeTrackersButtonsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [typeTrackersButtonsStack].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            typeTrackersButtonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typeTrackersButtonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            typeTrackersButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            typeTrackersButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func addNewButton(with title: String, action: Selector) -> UIButton {
        return UIButton(
            title: title,
            backgroundColor: .ypBlack,
            titleColor: .ypWhite,
            cornerRadius: 20,
            font: UIFont.systemFont(ofSize: 16),
            target: self,
            action: action
        )
    }
    
    private func setupCategoryUI() {
        [tableView, addCategoryButton, placeholder.view].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            placeholder.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateCategoryUI() {
        placeholder.view.isHidden = !categories.isEmpty
        addCategoryButton.isEnabled = !isAddingCategory
        addCategoryButton.backgroundColor = isAddingCategory ? .ypGray : .ypBlack
        addCategoryButton.setTitle(isAddingCategory ? "Готово" : buttonTitle, for: .normal)
        tableView.reloadData()
    }
    
    @objc private func createNewTracker() {
        let newTrackersVC = CreatingTrackerViewController(title: "Новая привычка")
        let navController = UINavigationController(rootViewController: newTrackersVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func addCategoryButtonAction() {
        if isAddingCategory {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextViewCell,
               let categoryText = cell.getText().text, !categoryText.isEmpty {
                categories.append(categoryText)
            }
            isAddingCategory.toggle()
        } else {
            isAddingCategory.toggle()
        }
        updateCategoryUI()
    }
}


// MARK: - UITableViewDelegate
extension BaseViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension BaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return TrackerSection.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            
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
        }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
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
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
                
            case .buttons:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ButtonCell.reuseIdentifier,
                    for: indexPath
                ) as? ButtonCell else {
                    return UITableViewCell()
                }
                configureButtonCell(cell, at: indexPath)
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
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                return cell
            }
        }
    
    private func configureButtonCell(
        _ cell: ButtonCell,
        at indexPath: IndexPath) {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 15
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
                cell.contentConfiguration = content
            } else {
                cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
            }
            
            let separator = UIView(frame: CGRect(
                x: 20,
                y: cell.frame.height - 1,
                width: cell.frame.width - 40,
                height: 1)
            )
            separator.backgroundColor = .lightGray
            if indexPath.row == 0 {
                cell.addSubview(separator)
            }
        }
}

// MARK: - TextViewCellDelegate
extension BaseViewController: TextViewCellDelegate {
    func textViewCellDidReachLimit(_ cell: TextViewCell) {}
    
    func textViewCellDidFallBelowLimit(_ cell: TextViewCell) {}
    
    func textViewCellDidChange(_ cell: TextViewCell) {}
    
    func textViewCellDidBeginEditing(_ cell: TextViewCell) {
        self.title = "Создание привычки"
    }
    func textViewCellDidEndEditing(_ cell: TextViewCell, text: String?) {}
}
