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
    var visibleCategories: [TrackerCategory] { get set }
    var completedTrackers: Set<TrackerRecord> { get set }
    var currentDate: Date { get set }
    
    func updatePlaceholder(isSearchActive: Bool)
    func reloadData()
    func updateFilterButtonVisibility()
}

// MARK: - Object
final class TrackersViewController: LaunchViewController {
    
    var presenter: TrackersPresenterProtocol?
    var categories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date()
    
    private var currentFilter: TrackerFilter = .allTrackers
    
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
        picker.backgroundColor = .ypLightGray
        picker.overrideUserInterfaceStyle = .light
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.tintColor = .systemBlue
        picker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(
            self,
            action: #selector(datePickerValueChanged),
            for: .valueChanged
        )
        return picker
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = LocalizationKey.searchPlaceholder.localized()
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.barTintColor = .systemBlue
        searchController.searchBar.tintColor = .systemBlue
        return searchController
    }()
    
    private lazy var filterButtonItem: UIButton = {
        let button = UIButton()
        button.setTitle(LocalizationKey.filtersButton.localized(), for: .normal)
        button.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .regular
        )
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var addNewTrackerButtonItem: UIBarButtonItem = {
        let button = UIButton()
        button.tintColor = .ypBlack
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.addTarget(
            self,
            action: #selector(leftBarButtonTapped),
            for: .touchUpInside
        )
        let barButtonItem = UIBarButtonItem(customView: button)
        
        return barButtonItem
    }()
    
    private lazy var calendarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(customView: datePicker)
        return barButtonItem
    }()
    
    init() {
        super.init(
            type: .trackers,
            placeholderImageName: PHName.trackersPH.rawValue,
            placeholderText: LocalizationKey.trackersPlaceholder.localized()
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .trackerCreated,
            object: nil
        )
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addNotification()
        presenter?.filterTrackers(for: currentDate, searchText: nil, filter: currentFilter)
        presenter?.loadCompletedTrackers()
        updatePlaceholder(isSearchActive: false)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsService.logEvent(
            event: AnalyticsReport.AnalyticsEventInfo.openScreen,
            screen: AnalyticsReport.AnalyticsScreenInfo.main,
            item: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.logEvent(
            event: AnalyticsReport.AnalyticsEventInfo.closeScreen,
            screen: AnalyticsReport.AnalyticsScreenInfo.main,
            item: nil
        )
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(filterButtonItem)
        
        NSLayoutConstraint.activate([
            filterButtonItem.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButtonItem.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButtonItem.widthAnchor.constraint(equalToConstant: 114),
            filterButtonItem.heightAnchor.constraint(equalToConstant: 50)
        ])
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerUpdated),
            name: .trackerUpdated,
            object: nil
        )
    }
    
    func updatePlaceholder(isSearchActive: Bool) {
        let isFilteringActive = currentFilter != .allTrackers && currentFilter != .today
        let isSearchOrFilteringActive = isSearchActive || isFilteringActive
        let categoriesToCheck = isSearchOrFilteringActive ? visibleCategories : categories
        let hasData = categoriesToCheck.contains { !$0.trackers.isEmpty }
        
        self.placeholderImageName = hasData
            ? PHName.trackersPH.rawValue
            : (isSearchOrFilteringActive
                ? PHName.searchPH.rawValue
                : PHName.trackersPH.rawValue)
        
        let placeholderLocalizationKey: LocalizationKey
        
        if hasData {
            placeholderLocalizationKey = .trackersPlaceholder
        } else {
            placeholderLocalizationKey = isSearchOrFilteringActive
            ? .notFoundSearchPlaceholder
            : .trackersPlaceholder
        }
        
        self.placeholderText = placeholderLocalizationKey.localized()

        placeholder.update(
            image: UIImage(named: placeholderImageName) ?? UIImage(),
            text: placeholderText
        )
        updatePlaceholderView(hasData: hasData)
    }
    
    func updateFilterButtonVisibility() {
        let hasTrackers = !visibleCategories.flatMap { $0.trackers }.isEmpty
        let isCompleteOrNotCompleteFilterActive = currentFilter == .completed || currentFilter == .uncompleted

        filterButtonItem.isHidden = !(hasTrackers || isCompleteOrNotCompleteFilterActive)
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.logEvent(event: "click", screen: "TrackersVC", item: "filter")
        
        let filterOptionsVC = FilterViewController(selectedFilter: currentFilter)
        let navController = UINavigationController(rootViewController: filterOptionsVC)
        filterOptionsVC.modalPresentationStyle = .formSheet
        filterOptionsVC.delegate = self
        self.present(navController, animated: true)
    }
}

// MARK: - NavigationController
extension TrackersViewController {
    
    func setupNavigationBar() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.hidesBarsOnSwipe = false
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = addNewTrackerButtonItem
        navigationItem.rightBarButtonItem = calendarButtonItem
        navigationItem.largeTitleDisplayMode = .always

        return navigationController
    }
    
    @objc private func leftBarButtonTapped() {
        AnalyticsService.logEvent(event: "click", screen: "TrackersVC", item: "add_track")
        
        let typeTrackerVC = TypeTrackersViewController(type: .typeTrackers)
        let navController = UINavigationController(rootViewController: typeTrackerVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true)
        
        collectionView.reloadData()
        updatePlaceholder(isSearchActive: false)
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate

        presenter?.filterTrackers(
            for: selectedDate,
            searchText: searchController.searchBar.text ?? "",
            filter: currentFilter
        )
        
        let isSearchActive = searchController.isActive
        updatePlaceholder(isSearchActive: isSearchActive)

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

            updatedTracker = Tracker(
                id: tracker.id,
                name: tracker.name,
                color: tracker.color,
                emoji: tracker.emoji,
                schedule: [],
                categoryTitle: categoryTitle,
                isRegularEvent: false,
                creationDate: creationDate,
                isPinned: false
            )
        }
        
        presenter?.addTracker(updatedTracker, categoryTitle: categoryTitle)
        presenter?.filterTrackers(for: currentDate, searchText: nil, filter: currentFilter)
    }
    
    @objc private func handleTrackerUpdated(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let updatedTracker = userInfo["tracker"] as? Tracker else {
            Logger.shared.log(
                .error,
                message: "Ошибка: не удалось извлечь трекер из уведомления."
            )
            return
        }
        
        presenter?.updateTracker(updatedTracker)
        presenter?.filterTrackers(for: currentDate, searchText: nil, filter: currentFilter)
    }
}

// MARK: - TrackersViewControllerProtocol
extension TrackersViewController: TrackersViewControllerProtocol {
    func reloadData() {
        collectionView.reloadData()
        updatePlaceholder(isSearchActive: false)
        updateFilterButtonVisibility()
    }
}

// MARK: - UISearchControllerDelegate, UISearchBarDelegate
extension TrackersViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.filterTrackers(for: currentDate, searchText: searchText, filter: currentFilter)
        
        updatePlaceholder(isSearchActive: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.filterTrackers(for: currentDate, searchText: nil, filter: currentFilter)
        
        updatePlaceholder(isSearchActive: false)
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.updateCancelButtonTitle()
        }
    }
    
    private func updateCancelButtonTitle() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self else { return }
            if let cancelButton = self.searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.setTitle(
                    LocalizationKey.searchCancel.localized(),
                    for: .normal
                )
            }
        }
    }
}

extension TrackersViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        applyFilter(filter)
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter

        if currentFilter == .today {
            currentDate = Date()
            datePicker.date = currentDate
            datePickerValueChanged(datePicker)
        } else {
            presenter?.filterTrackers(
                for: currentDate,
                searchText: searchController.searchBar.text,
                filter: currentFilter
            )
        }

        updatePlaceholder(isSearchActive: searchController.isActive)

        if currentFilter != .allTrackers && currentFilter != .today {
            filterButtonItem.setTitleColor(.red, for: .normal)
        } else {
            filterButtonItem.setTitleColor(.white, for: .normal)
        }
    }
}
