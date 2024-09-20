//
//  Tracker.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import UIKit

struct Tracker: Codable, Hashable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [String]
    let categoryTitle: String
    let isRegularEvent: Bool
    let creationDate: Date?
    var isPinned: Bool
    var originalCategoryTitle: String?
    //var isCompleted: Bool
}

extension Tracker {
    init(from coreData: TrackerCoreData) {
        self.id = coreData.id ?? UUID()
        self.name = coreData.name ?? ""
        self.color = coreData.color ?? ""
        self.emoji = coreData.emoji ?? ""
        self.categoryTitle = coreData.categoryTitle ?? ""
        self.isRegularEvent = coreData.isRegularEvent
        self.creationDate = coreData.creationDate ?? Date()
        self.isPinned = coreData.isPinned
        self.originalCategoryTitle = coreData.originalCategoryTitle
        //self.isCompleted = coreData.isCompleted

        if let scheduleString = coreData.schedule,
           let scheduleData = scheduleString.data(using: .utf8) {
            do {
                self.schedule = try JSONDecoder().decode([String].self, from: scheduleData)
            } catch {
                Logger.shared.log(
                    .error,
                    message: "Ошибка десериализации расписания для трекера: \(self.name)",
                    metadata: ["❌": error.localizedDescription]
                )
                self.schedule = []
            }
        } else {
            Logger.shared.log(
                .error,
                message: "Ошибка: расписание для трекера пустое или неверного формата: \(self.name)"
            )
            self.schedule = []
        }
    }
}
