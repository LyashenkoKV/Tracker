//
//  OnboardingStatus.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 04.09.2024.
//

import Foundation

final class OnboardingStatus {
    private let onboardingKey = "hasSeenOnboarding"

    func setOnboardingSeen() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func hasSeenOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingKey)
    }
}
