//
//  FilterViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 19.09.2024.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FilterViewController: UIViewController {
    
    var selectedFilter: TrackerFilter
    weak var delegate: FilterViewControllerDelegate?
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let filters = [
        (NSLocalizedString("filters_all_trackers", comment: "Все трекеры"), TrackerFilter.allTrackers),
        (NSLocalizedString("filters_on_today", comment: "Трекеры на сегодня"), TrackerFilter.today),
        (NSLocalizedString("filters_complete", comment: "Завершённые"), TrackerFilter.completed),
        (NSLocalizedString("filters+not_complete", comment: "Не завершённые"), TrackerFilter.uncompleted)
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        setupUI()
        title = NSLocalizedString("filtets_title", comment: "Фильтры")
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return filters.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        
        ConfigureTableViewCellsHelper.configureBaseCell(cell, at: indexPath, totalRows: filters.count)
        ConfigureTableViewCellsHelper.configureSeparator(cell, isLastRow: filters.count == indexPath.row + 1)
        
        let filter = filters[indexPath.row]
        cell.textLabel?.text = filter.0
        
        if filter.1 == selectedFilter {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        selectedFilter = filters[indexPath.row].1
        Logger.shared.log(.debug, message: "Фильтр выбран: \(selectedFilter)")
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
}
