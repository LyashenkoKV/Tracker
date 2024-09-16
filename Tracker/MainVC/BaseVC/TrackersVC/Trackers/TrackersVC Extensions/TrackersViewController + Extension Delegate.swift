//
//  Extension + UICollectionDelegate.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 29.07.2024.
//

import UIKit

// MARK: - UICollectionViewDelegate
extension TrackersViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint) -> UIContextMenuConfiguration? {
            
            Logger.shared.log(.info, message: "Trying to show context menu for item at section: \(indexPath.section), row: \(indexPath.row)")
            
            guard indexPath.section < visibleCategories.count else {
                Logger.shared.log(.error, message: "Invalid section: \(indexPath.section), total sections: \(visibleCategories.count)")
                return nil
            }
            
            let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
            let contextMenuHelper = TrackersContextMenuHelper(
                tracker: tracker,
                indexPath: indexPath,
                presenter: presenter,
                viewController: self
            )
            
            Logger.shared.log(.info, message: "Context menu created for tracker: \(tracker.name)")
            
            return contextMenuHelper.createContextMenu()
        }
}
