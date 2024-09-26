//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 22.09.2024.
//

import Foundation
import AppMetricaCore

typealias AnalyticsEventParam = [AnyHashable: Any]

final class AnalyticsService {
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
    
    static func logEvent(event: String, screen: String, item: String? = nil) {
        var params: AnalyticsEventParam = [
            "event": event,
            "screen": screen
        ]
        if let item = item {
            params["item"] = item
        }
        AnalyticsService.report(event: event, params: params)
        
        Logger.shared.log(
            .debug,
            message: "Отправлено событие: \(event), screen: \(screen), item: \(item ?? "N/A")"
        )
    }
}

enum AnalyticsReport {
    enum AnalyticsEventInfo {
        static let openScreen = "open"
        static let closeScreen = "close"
        static let clickButton = "click"
    }
    
    enum AnalyticsScreenInfo {
        static let main = "Main"
    }
    
    enum AnalyticsItemListInfo {
        static let trackItems = "track"
        static let addTrackItems = "add_track"
        static let filterTrackItems = "filter"
        static let editTrackItems = "edit"
        static let deleteTrackItems = "delete"
    }
}
