//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 22.09.2024.
//

import Foundation
import AppMetricaCore

typealias AnalyticsEventParam = [AnyHashable: Any]

enum AnalyticsService {
    static func activate() {
        guard let apiKey = KeychainService.shared.get(valueFor: GlobalConstants.appMetricaApiKey),
              let configuration = AppMetricaConfiguration(apiKey: apiKey) else {
            Logger.shared.log(.error, message: "Ошибка инициализации AppMetrica")
            return
        }

        AppMetrica.activate(with: configuration)
    }

    static func report(event: String, params: AnalyticsEventParam) {
        AppMetrica.reportEvent(name: event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}
