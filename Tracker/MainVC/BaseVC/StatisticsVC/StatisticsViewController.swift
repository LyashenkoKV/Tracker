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
            placeholderText: LocalizationKey.statisticsPlaceholder.localized()
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchStatistics()
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

extension StatisticsViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 4
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
        
        let statistic = viewModel.getStatistic(for: indexPath.row)
        
        let gradientColors: [UIColor] = [.systemRed,.systemGreen, .systemBlue]
        cell.configure(with: "\(statistic.value)", title: statistic.title, gradientColors: gradientColors)
        
        return cell
    }
}

extension StatisticsViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 90)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        let cellHeight: CGFloat = 90
        let minimumLineSpacing: CGFloat = 12
        let totalCellHeight = (cellHeight * CGFloat(numberOfItems)) + (minimumLineSpacing * CGFloat(numberOfItems - 1))
        let availableHeight = collectionView.bounds.height
        let topInset = max((availableHeight - totalCellHeight) / 2, 16)
        
        return UIEdgeInsets(top: topInset, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }
}
