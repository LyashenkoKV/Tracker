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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCardCell.reuseIdentifier,
                                                            for: indexPath) as? TrackersCardCell else { return UICollectionViewCell() }
        if case .category(_, let trackers) = categories[indexPath.section] {
            cell.configure(with: trackers[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else { return UICollectionViewCell() }
        if case .category(let title, _) = categories[indexPath.section] {
            print(title)
            header.addTitle(title)
        }
        return header
    }
    
}
