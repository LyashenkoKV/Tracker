//
//  FilterViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 19.09.2024.
//

import UIKit


//final class FilterViewController: UIViewController {
//
//    var selectedFilter: TrackerFilter
//       weak var delegate: FilterViewControllerDelegate?
//
//       init(selectedFilter: TrackerFilter) {
//           self.selectedFilter = selectedFilter
//           super.init(nibName: nil, bundle: nil)
//       }
//       
//       required init?(coder: NSCoder) {
//           fatalError("init(coder:) has not been implemented")
//       }
//       
//       private let filters = [
//           ("Все трекеры", TrackerFilter.allTrackers),
//           ("Трекеры на сегодня", TrackerFilter.today),
//           ("Завершённые", TrackerFilter.completed),
//           ("Не завершённые", TrackerFilter.uncompleted)
//       ]
//       
//       private lazy var tableView: UITableView = {
//           let tableView = UITableView()
//           tableView.delegate = self
//           tableView.dataSource = self
//           return tableView
//       }()
//       
//       override func viewDidLoad() {
//           super.viewDidLoad()
//           view.backgroundColor = .white
//           view.addSubview(tableView)
//           tableView.frame = view.bounds
//       }
//   }
//
//   // MARK: - UITableViewDelegate & UITableViewDataSource
//   extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
//       
//       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//           return filters.count
//       }
//       
//       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//           let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
//           let filter = filters[indexPath.row]
//           cell.textLabel?.text = filter.0
//           
//           if filter.1 == selectedFilter {
//               cell.accessoryType = .checkmark
//           } else {
//               cell.accessoryType = .none
//           }
//           
//           return cell
//       }
//       
//       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//           selectedFilter = filters[indexPath.row].1
//           delegate?.didSelectFilter(selectedFilter)
//           dismiss(animated: true, completion: nil)
//       }
//}
