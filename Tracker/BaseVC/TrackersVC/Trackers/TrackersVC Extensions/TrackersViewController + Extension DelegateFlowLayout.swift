//
//  TrackersViewController + UICollectionViewDelegateFlowLayout.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 02.08.2024.
//

import UIKit

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController {
   
    override func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalWidth = collectionView.frame.width - params.leftInset - params.rightInset
        let width = (totalWidth - params.cellSpacing) / 2
        return CGSize(width: width, height: width * 2 / 3 + 34)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let size = CGSize(width: collectionView.frame.width, height: 50)
        return size
    }
}
