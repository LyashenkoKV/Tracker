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
            let currentDate = dateFormatter.string(from: Date())
            
            var trackerId: UUID?
            if case .tracker(let id, _, _, _, _) = tracker {
                trackerId = id
            }
            
            guard let id = trackerId else { return UICollectionViewCell() }
            
            let isCompleted = presenter?.isTrackerCompleted(id, date: currentDate) ?? false
            cell.configure(with: tracker, isCompleted: isCompleted)
            
            cell.selectButtonTappedHandler = { [weak self] in
                self?.handleTrackerSelection(tracker, isCompleted: isCompleted)
            }
        }
        return cell
    }
    
    private func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool) {
        var trackerId: UUID?
        if case .tracker(let id, _, _, _, _) = tracker {
            trackerId = id
        }
        
        guard let id = trackerId else { return }
        
        let currentDate = dateFormatter.string(from: Date())
        
        if isCompleted {
            presenter?.trackerCompletedUnmark(id, date: currentDate)
        } else {
            presenter?.trackerCompletedMark(id, date: currentDate)
        }
        reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else { return UICollectionReusableView() }
        if case .category(let title, _) = categories[indexPath.section] {
            header.addTitle(title)
        }
        return header
    }
}
