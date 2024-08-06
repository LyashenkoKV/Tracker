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
    func reloadData()
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
        //picker.maximumDate = Date()
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
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(named: "Error"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size.height = 80
        imageView.frame.size.width = 80
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.accessibilityIdentifier = "TrackersCollectionView"
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
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Трекеры"
        view.backgroundColor = .ypWhite
        setupConstraints()
        updatePlaceholderView()
        presenter?.viewDidLoad()
        
        self.collectionView.register( // Перенести в свойство
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        
        self.collectionView.register(
            TrackersCardCell.self,
            forCellWithReuseIdentifier: TrackersCardCell.reuseIdentifier
        )
    }
    
    func configure(_ presenter: TrackersPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    private func setupConstraints() {
        [collectionView, placeholderView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [collectionView, placeholderView].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // Обновление состояния плейсхолдера
    func updatePlaceholderView() {
        let hasData = categories.contains { category in
            if case .category(_, let trackers) = category {
                return !trackers.isEmpty
            }
            return false
        }
        collectionView.isHidden = !hasData
        placeholderView.isHidden = hasData
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
        let typeTrackersVC = TypeTrackersViewController()
        let navController = UINavigationController(rootViewController: typeTrackersVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true, completion: nil)
        
//        guard let currentDateString = presenter?
//            .dateFormatter
//            .string(from: currentDate) else {
//            return
//        }
//        
//        let newTracker = Tracker.tracker(
//            id: UUID(),
//            name: "New Tracker",
//            color: .ypGreen,
//            emoji: "😀",
//            schedule: .dates([currentDateString])
//        )
//
//        presenter?.addTracker(newTracker, categotyTitle: "Default Category")
//        // Придумать как прикрутить добавление ячейки через performBatchUpdates, пока не хватает мозгов(
//        collectionView.reloadData()
//        updatePlaceholderView()
    }
    
    // Обработка изменения даты в пикере
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        collectionView.reloadData()
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
