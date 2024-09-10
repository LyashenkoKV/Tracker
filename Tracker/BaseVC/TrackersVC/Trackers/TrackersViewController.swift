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
}

// MARK: - Object
final class TrackersViewController: BaseViewController {
    
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
        picker.locale = Locale.current
        picker.tintColor = .systemBlue
        picker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.barTintColor = .systemBlue
        searchController.searchBar.tintColor = .systemBlue
        return searchController
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
    
    init() {
        super.init(placeholderImageName: PHName.trackersPH.rawValue, placeholderText: "Что будем отслеживать?")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .trackerCreated, object: nil)
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Трекеры"
        view.backgroundColor = .ypBackground
        updatePlaceholderView()
        addNotification()
        
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.register(
            TrackersCardCell.self,
            forCellWithReuseIdentifier: TrackersCardCell.reuseIdentifier
        )
        
        presenter?.filterTrackers(for: currentDate)
        presenter?.loadCompletedTrackers()
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
    
    func updatePlaceholderView() {
        let hasData = categories.contains { category in
            return !category.trackers.isEmpty
        }
        updatePlaceholderView(hasData: hasData)
    }
}

// MARK: - NavigationController
extension TrackersViewController {
    
    func setupNavigationBar() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.hidesBarsOnSwipe = false

        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.placeholder = "Поиск"
        navigationItem.leftBarButtonItem = addNewTrackerButtonItem
        navigationItem.rightBarButtonItem = calendarButtonItem
        navigationItem.largeTitleDisplayMode = .always

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

        let previousCompletedTrackersCount = completedTrackers.count
        presenter?.loadCompletedTrackers()
        if previousCompletedTrackersCount != completedTrackers.count {
            reloadData()
        }
    }
    
    @objc private func handleTrackerCreated(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let tracker = userInfo["tracker"] as? Tracker,
              let categoryTitle = userInfo["categoryTitle"] as? String else {
            Logger.shared.log(
                .error,
                message: "Ошибка: не удалось извлечь трекер или название категории из уведомления"
            )
            return
        }

        var updatedTracker = tracker

        if !tracker.isRegularEvent {
            let creationDate = currentDate
            let dayOfTheWeek = Calendar.current.component(.weekday, from: creationDate)
            let adjustedIndex = (dayOfTheWeek + 5) % 7
            let selectedDay = DayOfTheWeek.allCases[adjustedIndex]

            let selectedDayString = String(selectedDay.rawValue)

            updatedTracker = Tracker(
                id: tracker.id,
                name: tracker.name,
                color: tracker.color,
                emoji: tracker.emoji,
                schedule: [selectedDayString],
                categoryTitle: categoryTitle,
                isRegularEvent: tracker.isRegularEvent,
                creationDate: creationDate
            )
        }
        presenter?.addTracker(updatedTracker, categoryTitle: categoryTitle)
        presenter?.filterTrackers(for: currentDate)
    }
}

// MARK: - TrackersViewControllerProtocol
extension TrackersViewController: TrackersViewControllerProtocol {
    func reloadData() {
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
