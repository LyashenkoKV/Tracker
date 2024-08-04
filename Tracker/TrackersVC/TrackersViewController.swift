//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var categories: [TrackerCategory] { get set }
    var completedTrackers: [TrackerRecord] { get set }
    func reloadData()
}

final class TrackersViewController: UIViewController {
    
    private var presenter: TrackersPresenterProtocol?
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
   let params = GeometricParams(
        cellCount: 1,
        leftInset: 10,
        rightInset: 10,
        cellSpacing: 10
    )
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = " dd.MM.yy "
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
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
    
    private lazy var navigationBar: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: self)
        navigationItem.leftBarButtonItem = addNewTrackerButtonItem
        navigationItem.rightBarButtonItem = calendarButtonItem
        return navigationController
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.text = " Трекеры"
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.tintColor = .systemBlue
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.borderWidth = 0
        searchBar.searchTextField.layer.borderColor = UIColor.clear.cgColor
        return searchBar
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
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 50)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.accessibilityIdentifier = "TrackersCollectionView"
        return collectionView
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            searchBar,
            collectionView,
            placeholderView
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupConstraints()
        updatePlaceholderView()
        presenter?.viewDidLoad()
        
        self.collectionView.register(
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
        [titleLabel,
         searchBar,
         collectionView,
         placeholderView,
         verticalStackView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
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
        return navigationBar
    }
    
    @objc private func leftBarButtonTapped() {
        let newTracker = Tracker.tracker(
            id: UUID(),
            name: "New Tracker",
            color: .ypGreen,
            emoji: "😀",
            schedule: .dates(["01.08.2024"])
        )

        presenter?.addTracker(newTracker, categotyTitle: "Default Category")
        collectionView.reloadData()
        updatePlaceholderView()
        print("Add tracker")
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        dateFormatter.string(from: selectedDate)
    }
}

extension TrackersViewController: TrackersViewControllerProtocol {
    func reloadData() {
        collectionView.reloadData()
    }
}
