//
//  ViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit

final class MainViewController: UIViewController {
    
    private let trackersViewController = TrackersViewController()
    private let statisticViewController = StatisticsViewController()
    private var borderView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchToTapBarController()
    }
    
    private func switchToTapBarController() {
        guard let window = UIApplication.shared.windows.first else {
            Logger.shared.log(.error,
                              message: "SplashViewController: неверная конфигурация window",
                              metadata: ["❌": ""])
            return
        }
        
        let tabBarController = createTabBarController()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
    
    private func createTabBarController() -> UITabBarController {
        let trackersNavigationController = trackersViewController.setupNavigationBar()
        let statisticsNavigationController = statisticViewController.setupNavigationBar()

        let trackerStore = TrackerStore(persistentContainer: CoreDataStack.shared.persistentContainer)
        let categoryStore = TrackerCategoryStore(persistentContainer: CoreDataStack.shared.persistentContainer)
        let recordStore = TrackerRecordStore(persistentContainer: CoreDataStack.shared.persistentContainer)
        let trackersPresenter = TrackersPresenter(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )

        trackersViewController.configure(trackersPresenter)

        trackersViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString(
                "trackers_tab_title",
                comment: "Заголовок"
            ),
            image: UIImage(systemName: "smallcircle.filled.circle.fill"),
            tag: 0
        )
        statisticViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString(
                "statistics_tab_title",
                comment: "Заголовок"
            ),
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            trackersNavigationController,
            statisticsNavigationController,
        ]

        setupBorderView(for: tabBarController)
        tabBarController.tabBar.tintColor = .systemBlue
        
        return tabBarController
    }
    
    private func setupBorderView(for tabBarController: UITabBarController) {
        borderView.frame = CGRect(
            x: 0,
            y: 0,
            width: tabBarController.tabBar.frame.width,
            height: 1
        )
        borderView.backgroundColor = UIColor(named: "YPGrayDark")
        tabBarController.tabBar.addSubview(borderView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            borderView.backgroundColor = UIColor(named: "YPGrayDark")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tabBar = tabBarController?.tabBar {
            borderView.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1)
        }
    }
}
