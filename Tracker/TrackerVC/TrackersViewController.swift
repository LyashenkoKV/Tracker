//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let showSelectedDay: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = " dd.MM.yy "
        return dateFormatter.string(from: Date())
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.accessibilityIdentifier = "TrackersCollectionView"
        collectionView.register(TrackersCollectionViewCell.self, 
                                forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
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
    
    private lazy var addNewTrackerButtonItem: UIBarButtonItem = {
        let button = createCustomButton(
            imageName: "plus",
            title: nil,
            backgroundColor: nil,
            action: #selector(leftBarButtonTapped))
        let barButtonItem = UIBarButtonItem(customView: button)
        
        return barButtonItem
    }()
    
    private lazy var calendarButtonItem: UIBarButtonItem = {
        let button = createCustomButton(
            imageName: nil,
            title: showSelectedDay,
            backgroundColor: .ypLightGray,
            action: #selector(rightBarButtonTapped))
        let barButtonItem = UIBarButtonItem(customView: button)
        
        return barButtonItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupConstraints()
        updatePlaceholderView()
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
    
    private func updatePlaceholderView() {
        let hasData = collectionView.numberOfItems(inSection: 0) > 0
        collectionView.isHidden = !hasData
        placeholderView.isHidden = hasData
    }
}

// MARK: - NavigationController
extension TrackersViewController {
    
    func setupNavigationBar() -> UINavigationController {
        return navigationBar
    }
    
    private func createCustomButton(
        imageName: String?,
        title: String?,
        backgroundColor: UIColor?,
        action: Selector) -> UIButton {
            let button = UIButton(type: .system)
            
            if let imageName = imageName {
                button.setImage(UIImage(systemName: imageName), for: .normal)
            }
            if let title = title {
                button.setTitle(title, for: .normal)
            }
            button.addTarget(self, action: action, for: .touchUpInside)
            button.backgroundColor = backgroundColor
            button.tintColor = .ypBlack
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            button.sizeToFit()
            return button
        }
    
    @objc private func leftBarButtonTapped() {
        print("Left bar button tapped")
        // TODO
    }
    
    @objc private func rightBarButtonTapped() {
        print("Right bar button tapped")
        // TODO
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = 0
        
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier, for: indexPath)
        
        return cell
    }
}
