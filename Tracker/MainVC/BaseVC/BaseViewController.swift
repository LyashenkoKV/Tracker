//
//  BaseViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 10.09.2024.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    var placeholderImageName: String
    var placeholderText: String
    var viewControllerType: ViewControllerType?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var placeholder: Placeholder = {
        let placeholder = Placeholder(
            image: UIImage(named: placeholderImageName),
            text: placeholderText
        )
        return placeholder
    }()
    
    // MARK: - Initializer
    init(type: ViewControllerType,
        placeholderImageName: String,
        placeholderText: String
    ) {
        self.viewControllerType = type
        self.placeholderImageName = placeholderImageName
        self.placeholderText = placeholderText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePlaceholderView(hasData: false)
        configureUI()
        configureCell()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        [collectionView, placeholder.view].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func configureUI() {
        view.backgroundColor = .ypBackground
        
        switch viewControllerType {
        case .trackers:
            self.title = NSLocalizedString(
                "trackers_tab_title",
                comment: "Заголовок трекера"
            )
        case .statistics:
            self.title = NSLocalizedString(
                "statistics_tab_title",
                comment: "Заголовок статистики"
            )
        case .none:
            break
        }
    }
    
    private func configureCell() {
        switch viewControllerType {
        case .trackers:
            collectionView.register(
                SectionHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier
            )
            collectionView.register(
                TrackersCardCell.self,
                forCellWithReuseIdentifier: TrackersCardCell.reuseIdentifier
            )
        case .statistics:
            collectionView.register(
                StatisticCell.self,
                forCellWithReuseIdentifier: StatisticCell.reuseIdentifier
            )
        case .none:
            break
        }
    }
    
    // MARK: - Update Placeholder
    func updatePlaceholderView(hasData: Bool) {
        collectionView.isHidden = !hasData
        placeholder.view.isHidden = hasData
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension BaseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension BaseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
