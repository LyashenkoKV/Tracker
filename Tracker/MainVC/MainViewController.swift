//
//  ViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit

final class MainViewController: UIViewController {
    
    private let trackersViewController = TrackersViewController()
    private let statisticViewController = StatisticViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchToTapBarController()
        UserDefaults.standard.clearSavedData()
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
        let navigationController = trackersViewController.setupNavigationBar()
        
        trackersViewController.configure(TrackersPresenter(view: trackersViewController))
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "smallcircle.filled.circle.fill"),
            tag: 0
        )
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )
        
        let tabBarController = UITabBarController()
        
        tabBarController.viewControllers = [
            navigationController,
            statisticViewController
        ]
        
        tabBarController.tabBar.tintColor = .systemBlue
        tabBarController.tabBar.layer.borderColor = UIColor.lightGray.cgColor
        tabBarController.tabBar.layer.borderWidth = 1
        tabBarController.tabBar.clipsToBounds = true
        
        return tabBarController
    }
}
