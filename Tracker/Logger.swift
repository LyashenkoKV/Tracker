//
//  Logger.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 25.07.2024.
//

import Foundation
import os.log

final class Logger {
    static let shared = Logger()
    
    private let logger: OSLog
    
    private init() {
        logger = OSLog(
            subsystem: "ru.yandex.practicum.Tracker",
            category: "network"
        )
    }
    
    func log(
        _ level: OSLogType,
        message: @autoclosure () -> String,
        metadata: [String: String]? = nil
    ) {
        let metaString = metadata?.map { "\($0.key): \($0.value)" }.joined(separator: ", ") ?? ""
        let finalMessage = metaString.isEmpty ? message() : "\(message()) | Metadata: \(metaString)"
        os_log("%{public}@", log: logger, type: level, finalMessage)
    }
}

