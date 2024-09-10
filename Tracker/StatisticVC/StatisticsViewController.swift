//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private let viewModel = StatisticsViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(StatisticCell.self, forCellWithReuseIdentifier: StatisticCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var placeholder: Placeholder = {
        let placeholder = Placeholder(
            image: UIImage(named: PHName.statisticPH.rawValue),
            text: "Анализировать пока нечего"
        )
        return placeholder
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        self.title = "Статистика"
        setupUI()
        updatePlaceholderView()
    }
    
    private func setupUI() {
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
        let hasData = viewModel.hasStatistics
        
        collectionView.isHidden = !hasData
        placeholder.view.isHidden = hasData
        
        if hasData {
            collectionView.reloadData()
        }
    }
    
    func setupNavigationBar() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.hidesBarsOnSwipe = false
        navigationItem.largeTitleDisplayMode = .always

        return navigationController
    }
}

// MARK: - UICollectionViewDataSource
extension StatisticsViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 4
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "StatisticCell",
            for: indexPath
        ) as? StatisticCell ?? UICollectionViewCell()
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension StatisticsViewController: UICollectionViewDelegate {
    
}
