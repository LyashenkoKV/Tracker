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
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPath.section < visibleCategories.count else {
            return nil
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let contextMenuHelper = TrackersContextMenuHelper(
            tracker: tracker,
            indexPath: indexPath,
            presenter: presenter,
            viewController: self,
            completedTrackers: completedTrackers
        )
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCardCell else {
                return nil
            }
            
            let previewViewController = UIViewController()
            previewViewController.view = cell.messageStack.snapshotView(afterScreenUpdates: true)
            previewViewController.preferredContentSize = cell.messageStack.bounds.size
            return previewViewController
        }, actionProvider: { _ in
            return contextMenuHelper.createContextMenu()
        })
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?) {
            
            animator?.addCompletion { [weak self] in
                guard let self = self else { return }
                
                if let indexPath = configuration.identifier as? IndexPath {
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? TrackersCardCell {
                        cell.setNeedsLayout()
                        cell.layoutIfNeeded()
                    }
                }
            }
        }
}

