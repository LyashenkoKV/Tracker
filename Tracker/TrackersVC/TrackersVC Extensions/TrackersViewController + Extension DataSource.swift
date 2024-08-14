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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if case .category(_, let trackers) = categories[section] {
            return trackers.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCardCell.reuseIdentifier,
            for: indexPath) as? TrackersCardCell else { return UICollectionViewCell() }
        
        if case .category(_, let trackers) = categories[indexPath.section] {
            let tracker = trackers[indexPath.row]
            let currentDateString = presenter?.dateFormatter.string(from: currentDate) ?? ""
            
            var trackerId: UUID?
            var isRegularEvent = false
            
            if case let .tracker(id, _, _, _, _, _, regularEvent) = tracker {
                trackerId = id
                isRegularEvent = regularEvent
            }
            
            guard let id = trackerId else { return UICollectionViewCell() }

            let isCompletedToday = completedTrackers.contains { record in
                if case let .record(trackerId, date) = record {
                    return trackerId == id && date == currentDateString
                }
                return false
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
                if isDateValidForCompletion {
                    self.presenter?.handleTrackerSelection(tracker, isCompleted: isCompletedToday)
                    
                    collectionView.reloadItems(at: [indexPath])
                } else {
                    print("Нельзя отметить будущую дату как выполненную")
                }
            }
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath) as? SectionHeaderView else { return UICollectionReusableView() }
        if case .category(let title, _) = categories[indexPath.section] {
            header.addTitle(title)
        }
        return header
    }
}
