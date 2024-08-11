//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

//final class CreatingTrackerViewController: UIViewController {
//
//    private var titleVC: String?
//    var isFooterVisible = false
//    var categorySubtitle = ""
//    var selectedCategories: [String] = []
//
//    private lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: .zero, style: .grouped)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseIdentifier)
//        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
//        tableView.register(EmojiesAndColorsTableViewCell.self, forCellReuseIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier)
//        tableView.register(CreateButtonsViewCell.self, forCellReuseIdentifier: CreateButtonsViewCell.reuseIdentifier)
//        tableView.backgroundColor = .ypWhite
//        tableView.separatorStyle = .none
//        tableView.showsVerticalScrollIndicator = false
//        tableView.showsHorizontalScrollIndicator = false
//        return tableView
//    }()
//    
//    var emojies = [
//        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
//        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
//        "🥦", "🏓", "🥇", "🎸", "🌴", "😪"
//    ]
//    
//    var colors = [
//        "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
//        "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
//        "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
//    ]
//
//    init(title: String) {
//        self.titleVC = title
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .ypWhite
//        self.title = titleVC
//        setupLayout()
//    }
//    
//    private func setupLayout() {
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//        ])
//    }
//    
//    private func collectTrackerData() -> Tracker {
//        let name = ""
//        let emoji = ""
//        let color: UIColor = .ypWhite
//        let schedule: [String] = []
//        
//        return Tracker.tracker(
//            id: UUID(),
//            name: name,
//            color: color,
//            emoji: emoji,
//            schedule: .dayOfTheWeek(schedule)
//        )
//    }
//}
//
//// MARK: - TextViewCellDelegate
//extension CreatingTrackerViewController: TextViewCellDelegate {
//    func textViewCellDidReachLimit(_ cell: TextViewCell) {
//        isFooterVisible = true
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }
//    
//    func textViewCellDidFallBelowLimit(_ cell: TextViewCell) {
//        isFooterVisible = false
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }
//    
//    func textViewCellDidChange(_ cell: TextViewCell) {}
//    
//    func textViewCellDidBeginEditing(_ cell: TextViewCell) {
//        self.title = "Создание привычки"
//    }
//    func textViewCellDidEndEditing(_ cell: TextViewCell, text: String?) {}
//}
//
//// MARK: - CategorySelectionDelegate
//extension CreatingTrackerViewController: CategorySelectionDelegate {
//    func didSelectCategories(_ categories: [String], and category: String) {
//        self.selectedCategories = categories
//        self.categorySubtitle = category
//        tableView.reloadData()
//    }
//}
final class CreatingTrackerViewController: BaseTrackerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
