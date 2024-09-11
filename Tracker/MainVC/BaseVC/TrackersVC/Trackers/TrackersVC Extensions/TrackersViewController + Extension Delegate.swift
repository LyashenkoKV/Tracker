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
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(
                title: NSLocalizedString(
                    "delete",
                    comment: "Удалить трекер"
                ),
                attributes: .destructive) { [weak self] _ in
                self?.presenter?.deleteTracker(at: indexPath)
            }
            
            let editAction = UIAction(
                title: NSLocalizedString(
                    "edit",
                    comment: "Редактировать трекер"
                )
            ) { [weak self] _ in
                self?.presenter?.editTracker(at: indexPath)
            }
            
            return UIMenu(
                title: "",
                children: [editAction, deleteAction]
            )
        }
        return config
    }
}
