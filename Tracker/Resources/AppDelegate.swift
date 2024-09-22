//
//  AppDelegate.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import UIKit
import CoreData
import AppMetricaCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if KeychainService.shared.get(valueFor: "apiKey") == nil {
            _ = KeychainService.shared.set(value: "1f223b95-a149-4bfd-b3fe-905866840858", for: "apiKey")
        }
        
        AnalyticsService.activate()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.shared.saveContext()
    }
}

