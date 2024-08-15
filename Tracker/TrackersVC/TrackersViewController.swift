//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit
// MARK: - Protocol
protocol TrackersViewControllerProtocol: AnyObject {
    var categories: [TrackerCategory] { get set }
    var completedTrackers: Set<TrackerRecord> { get set }
    var currentDate: Date { get set }
    func updatePlaceholderView()
    func reloadData()
    //func reloadDataWithBatchUpdates(insertedSections: IndexSet?, insertedIndexPaths: [IndexPath]?)
}

// MARK: - Object
final class TrackersViewController: UIViewController {
    
    var presenter: TrackersPresenterProtocol?
    
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date()
    
    let params = GeometricParams(
        cellCount: 1,
        leftInset: 10,
        rightInset: 10,
        cellSpacing: 10
    )
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.tintColor = .ypBlack
        picker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = .systemBlue
        searchController.searchBar.tintColor = .systemBlue
        searchController.searchBar.delegate = self
        searchController.delegate = self
        return searchController
    }()
    
    private lazy var placeholder: Placeholder = {
        let placeholder = Placeholder(image: UIImage(named: "Error"), text: "Что будем отслеживать?")
        return placeholder
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.accessibilityIdentifier = "TrackersCollectionView"
        
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.register(
            TrackersCardCell.self,
            forCellWithReuseIdentifier: TrackersCardCell.reuseIdentifier
        )
        return collectionView
    }()
    
    // MARK: - BarButtonItems
    private lazy var addNewTrackerButtonItem: UIBarButtonItem = {
        let button = UIButton()
        button.tintColor = .ypBlack
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.addTarget(self, action: #selector(leftBarButtonTapped), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        
        return barButtonItem
    }()
    
    private lazy var calendarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(customView: datePicker)
        return barButtonItem
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .trackerCreated, object: nil)
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Трекеры"
        view.backgroundColor = .ypWhite
        setupConstraints()
        updatePlaceholderView()
        addNotification()
//        
//        presenter?.loadTrackers()
//        presenter?.loadCompletedTrackers()
    }
    
    func configure(_ presenter: TrackersPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerCreated),
            name: .trackerCreated,
            object: nil
        )
    }

    private func setupConstraints() {
        [collectionView, placeholder.view].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            placeholder.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func updatePlaceholderView() {
        let hasData = categories.contains { category in
            return !category.trackers.isEmpty
        }
        collectionView.isHidden = !hasData
        placeholder.view.isHidden = hasData
    }
//    
//    func reloadDataWithBatchUpdates(
//        insertedSections: IndexSet? = nil,
//        insertedIndexPaths: [IndexPath]? = nil) {
//        collectionView.performBatchUpdates {
//            if let sections = insertedSections {
//                collectionView.insertSections(sections)
//            }
//            if let indexPaths = insertedIndexPaths {
//                collectionView.insertItems(at: indexPaths)
//            }
//        }
//        updatePlaceholderView()
//    }
//    
    func deleteTracker(at indexPath: IndexPath) {
        let updatedCategories = categories.enumerated().map { (index, category) -> TrackerCategory in
            if index == indexPath.section {
                var updatedTrackers = category.trackers
                updatedTrackers.remove(at: indexPath.row)
                return TrackerCategory(title: category.title, trackers: updatedTrackers)
            } else {
                return category
            }
        }
        categories = updatedCategories
        
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        }
        updatePlaceholderView()
    }
    
    func editTracker(at indexPath: IndexPath) {
    }
}

// MARK: - NavigationController
extension TrackersViewController {
    
    func setupNavigationBar() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.placeholder = "Поиск"
        navigationItem.leftBarButtonItem = addNewTrackerButtonItem
        navigationItem.rightBarButtonItem = calendarButtonItem
        return navigationController
    }
    
    // Обработка нажатия на кнопку добавления трекера
    @objc private func leftBarButtonTapped() {
        let typeTrackerVC = TypeTrackersViewController(type: .typeTrackers)
        let navController = UINavigationController(rootViewController: typeTrackerVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true)
        
        collectionView.reloadData()
        updatePlaceholderView()
    }

    // Обработка изменения даты в пикере
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        presenter?.filterTrackers(for: selectedDate)
        presenter?.loadCompletedTrackers()
        reloadData()
    }
    
    @objc private func handleTrackerCreated(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let tracker = userInfo["tracker"] as? Tracker,
              let categoryTitle = userInfo["categoryTitle"] as? String else {
            return
        }

        var updatedTracker = tracker

        if !tracker.isRegularEvent {
            let creationDate = currentDate
            let dayOfTheWeek = Calendar.current.component(.weekday, from: creationDate)
            let adjustedIndex = (dayOfTheWeek + 5) % 7
            let selectedDay = DayOfTheWeek.allCases[adjustedIndex]

            updatedTracker = Tracker(
                id: tracker.id,
                name: tracker.name,
                color: tracker.color,
                emoji: tracker.emoji,
                schedule: Schedule(days: [selectedDay]),
                categoryTitle: categoryTitle,
                isRegularEvent: tracker.isRegularEvent, 
                creationDate: creationDate
            )
            
            print("updatedTracker \(updatedTracker)")
        }
        presenter?.addTracker(updatedTracker, categotyTitle: categoryTitle)
    }
}

// MARK: - TrackersViewControllerProtocol
extension TrackersViewController: TrackersViewControllerProtocol {
    func reloadData() {
        print("Количество трекеров перед обновлением: \(categories.flatMap { $0.trackers }.count)")
        collectionView.reloadData()
        updatePlaceholderView()
    }
}

// MARK: - UISearchControllerDelegate, UISearchBarDelegate
extension TrackersViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            self.updateCancelButtonTitle()
        }
    }
    
    private func updateCancelButtonTitle() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Тут есть проблема с обновлением тайтла кнопки
            if let cancelButton = self.searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.setTitle("Отменить", for: .normal)
            }
        }
    }
}
