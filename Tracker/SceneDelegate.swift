//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let onboardingStatus = OnboardingStatus()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        if onboardingStatus.hasSeenOnboarding() {
            let mainViewController = MainViewController()
            window.rootViewController = mainViewController
        } else {
            let onboardingPageViewController = OnboardingPageViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal
            )
            window.rootViewController = onboardingPageViewController
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
}

