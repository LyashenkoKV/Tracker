//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit

final class StatisticsViewController: BaseViewController {
    
    private let viewModel = StatisticsViewModel()
    
    init() {
        super.init(
            type: .statistics,
            placeholderImageName: PHName.statisticPH.rawValue,
            placeholderText: "Анализировать пока нечего"
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlaceholderView()
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
extension StatisticsViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 1
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StatisticCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension StatisticsViewController {
    
}
