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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCardCell.reuseIdentifier, for: indexPath) as? TrackersCardCell else { return UICollectionViewCell() }
        if case .category(_, let trackers) = categories[indexPath.section] {
            let tracker = trackers[indexPath.row]
            let currentDateString = presenter?.dateFormatter.string(from: currentDate) ?? ""
            
            var trackerId: UUID?
            if case .tracker(let id, _, _, _, _) = tracker {
                trackerId = id
            }
            
            guard let id = trackerId else { return UICollectionViewCell() }
            
            let isCompleted = presenter?.isTrackerCompleted(id, date: currentDateString) ?? false
            let isDateValidForCompletion = presenter?.isDateValidForCompletion(date: currentDate) ?? false
            
            cell.configure(with: tracker, 
                           countComplete: completedTrackers,
                           isCompleted: isCompleted,
                           isDateValidForCompletion: isDateValidForCompletion)
            
            cell.selectButtonTappedHandler = { [weak self] in
                guard let self else { return }
                if isDateValidForCompletion {
                    self.presenter?.handleTrackerSelection(tracker, isCompleted: isCompleted)
                } else {
                    print("Нельзя отметить будущую дату как выполненную")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else { return UICollectionReusableView() }
        if case .category(let title, _) = categories[indexPath.section] {
            header.addTitle(title)
        }
        return header
    }
}
