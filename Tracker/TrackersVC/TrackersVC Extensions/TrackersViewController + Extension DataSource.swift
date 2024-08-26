//
//  Extension + UICollectionViewDataSource.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 29.07.2024.
//

import UIKit

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCardCell.reuseIdentifier,
            for: indexPath
        ) as? TrackersCardCell else {
            Logger.shared.log(.error, message: "Не удалось деактивировать TrackersCardCell")
            return UICollectionViewCell()
        }
        
        let trackers = categories[indexPath.section].trackers
        let tracker = trackers[indexPath.row]
        Logger.shared.log(.info, message: "Настройка ячейки для трекера: \(tracker.name) в секции \(indexPath.section), строке \(indexPath.row)")
        
        let currentDateString = presenter?.dateFormatter.string(from: currentDate) ?? ""
        let trackerId = tracker.id
        let isRegularEvent = tracker.isRegularEvent
        
        let isCompletedToday = completedTrackers.contains { record in
            return record.trackerId == trackerId && record.date == currentDateString
        }
        Logger.shared.log(.info, message: "Трекер \(tracker.name) выполнен сегодня: \(isCompletedToday)")
        
        let isDateValidForCompletion = presenter?.isDateValidForCompletion(date: currentDate) ?? false
        Logger.shared.log(.info, message: "Дата валидна для завершения трекера \(tracker.name): \(isDateValidForCompletion)")
        
        cell.configure(
            with: tracker,
            countComplete: completedTrackers,
            isCompleted: isCompletedToday,
            isDateValidForCompletion: isDateValidForCompletion,
            isRegularEvent: isRegularEvent
        )
        
        cell.selectButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            
            if isDateValidForCompletion {
                Logger.shared.log(.info, message: "Обработка выбора трекера \(tracker.name)")
                self.presenter?.handleTrackerSelection(
                    tracker,
                    isCompleted: isCompletedToday,
                    date: self.currentDate
                )
                
                collectionView.reloadItems(at: [indexPath])
            } else {
                Logger.shared.log(.error, message: "Нельзя отметить будущую дату как выполненную для трекера \(tracker.name)")
                print("Нельзя отметить будущую дату как выполненную")
            }
        }
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath) as? SectionHeaderView else { return UICollectionReusableView() }
        
        let title = categories[indexPath.section].title
        header.addTitle(title)
        
        return header
    }
}
