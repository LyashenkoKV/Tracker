//
//  Extension + UICollectionViewDataSource.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 29.07.2024.
//

import UIKit

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, 
                        numberOfItemsInSection section: Int) -> Int {
        let itemCount = 0
        
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        
        return cell
    }
}
