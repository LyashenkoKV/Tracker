//
//  StatisticsStore.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 22.09.2024.
//

import Foundation
import CoreData

final class StatisticsStore {
    private let persistentContainer: NSPersistentContainer
    private let fetchedResultsController: NSFetchedResultsController<StatisticsCoreData>

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        
        let fetchRequest: NSFetchRequest<StatisticsCoreData> = StatisticsCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "bestPeriod", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.shared.log(.error, message: "Ошибка при загрузке статистики из Core Data")
        }
    }

    func fetchStatistics() -> StatisticsData? {
        if let statisticsCoreData = fetchedResultsController.fetchedObjects?.first {
            return StatisticsData(
                bestPeriod: Int(statisticsCoreData.bestPeriod),
                idealDays: Int(statisticsCoreData.idealDays),
                completedTrackers: Int(statisticsCoreData.completedTrackers),
                averageValue: Int(statisticsCoreData.averageValue)
            )
        } else {
            return nil
        }
    }
    
    func saveStatistics(bestPeriod: Int, idealDays: Int, completedTrackers: Int, averageValue: Int) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<StatisticsCoreData> = StatisticsCoreData.fetchRequest()
        
        do {
            if let statisticsCoreData = try context.fetch(fetchRequest).first {
                statisticsCoreData.bestPeriod = Int16(bestPeriod)
                statisticsCoreData.idealDays = Int16(idealDays)
                statisticsCoreData.completedTrackers = Int16(completedTrackers)
                statisticsCoreData.averageValue = Int16(averageValue)
            } else {
                let newStatistics = StatisticsCoreData(context: context)
                newStatistics.bestPeriod = Int16(bestPeriod)
                newStatistics.idealDays = Int16(idealDays)
                newStatistics.completedTrackers = Int16(completedTrackers)
                newStatistics.averageValue = Int16(averageValue)
            }
            try context.save()
        } catch {
            Logger.shared.log(.error, message: "Ошибка при сохранении статистики: \(error.localizedDescription)")
        }
    }
}
