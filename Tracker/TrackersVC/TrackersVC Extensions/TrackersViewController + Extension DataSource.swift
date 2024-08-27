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
            for: indexPath) as? TrackersCardCell else { return UICollectionViewCell() }
        
        let trackers = categories[indexPath.section].trackers
        let tracker = trackers[indexPath.row]
        let currentDateString = presenter?.dateFormatter.string(from: currentDate) ?? ""
        let trackerId = tracker.id
        let isRegularEvent = tracker.isRegularEvent
        
        let isCompletedToday = completedTrackers.contains { record in
            return record.trackerId == trackerId && record.date == currentDateString
        }
        
        let isDateValidForCompletion = presenter?.isDateValidForCompletion(date: currentDate) ?? false
        
        cell.configure(
            with: tracker,
            countComplete: completedTrackers,
            isCompleted: isCompletedToday,
            isDateValidForCompletion: isDateValidForCompletion,
            isRegularEvent: isRegularEvent
        )
        
        cell.selectButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            
            Logger.shared.log(.info, message: "Кнопка завершения трекера нажата для \(tracker.name) (ID: \(tracker.id))")
            
            if isDateValidForCompletion {
                Logger.shared.log(.info, message: "Дата валидна для завершения трекера \(tracker.name)")
                
                self.presenter?.handleTrackerSelection(
                    tracker,
                    isCompleted: isCompletedToday,
                    date: self.currentDate
                )
                
                Logger.shared.log(.info, message: "Данные трекера \(tracker.name) обновлены, перезагрузка ячейки")
                collectionView.reloadItems(at: [indexPath])
            } else {
                Logger.shared.log(.info, message: "Попытка отметить будущую дату как выполненную для трекера \(tracker.name)")
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
