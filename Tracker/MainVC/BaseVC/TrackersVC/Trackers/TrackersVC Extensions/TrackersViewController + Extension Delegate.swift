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
            let pin = UIAction(
                title: NSLocalizedString(
                    "pin",
                    comment: "Закрепить"
                )) { [weak self] _ in
                    print("Pin")
                }
            
            let deleteAction = UIAction(
                title: NSLocalizedString(
                    "delete",
                    comment: "Удалить трекер"
                ),
                attributes: .destructive) { [weak self] _ in
                self?.showDeleteConfirmationAlert(at: indexPath)
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
                children: [pin, editAction, deleteAction]
            )
        }
        return config
        }
    
    private func showDeleteConfirmationAlert(at indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: NSLocalizedString(
                "delete_confirmation_message",
                comment: "Уверены что хотите удалить трекер?"
            ),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString(
                "delete",
                comment: "Удалить"
            ),
            style: .destructive
        ) { [weak self] _ in
            self?.presenter?.deleteTracker(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString(
                "alert_cancel",
                comment: "Отменить"
            ),
            style: .cancel
        )
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
