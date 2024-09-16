//
//  ContextMenuHelper.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 16.09.2024.
//

import UIKit

// MARK: - TrackersContextMenuHelper
final class TrackersContextMenuHelper {

    // MARK: - Properties
    private let tracker: Tracker
    private let indexPath: IndexPath
    private var presenter: TrackersPresenterProtocol?
    private var viewController: UIViewController?

    // MARK: - Init
    init(tracker: Tracker,
         indexPath: IndexPath,
         presenter: TrackersPresenterProtocol?,
         viewController: UIViewController?) {
        self.tracker = tracker
        self.indexPath = indexPath
        self.presenter = presenter
        self.viewController = viewController
    }

    // MARK: - Create Context Menu
    func createContextMenu() -> UIContextMenuConfiguration {
        Logger.shared.log(.info, message: "Creating context menu for tracker: \(tracker.name)")
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

            let pinTitle = self.tracker.isPinned
                ? NSLocalizedString("unpin", comment: "Открепить")
                : NSLocalizedString("pin", comment: "Закрепить")
            
            Logger.shared.log(.info, message: "Pin action title: \(pinTitle)")

            let pinAction = UIAction(
                title: pinTitle
            ) { _ in
                Logger.shared.log(.info, message: "\(pinTitle) action selected for tracker: \(self.tracker.name)")
                self.presenter?.togglePin(for: self.tracker)
            }

            let deleteAction = UIAction(
                title: NSLocalizedString("delete", comment: "Удалить"),
                attributes: .destructive
            ) { _ in
                self.showDeleteConfirmationAlert()
            }

            let editAction = UIAction(
                title: NSLocalizedString("edit", comment: "Редактировать")
            ) { _ in
                Logger.shared.log(.info, message: "Edit action selected for tracker: \(self.tracker.name)")
                self.presenter?.editTracker(at: self.indexPath)
            }
            
            Logger.shared.log(.info, message: "Context menu created successfully")

            return UIMenu(
                title: "",
                children: [pinAction, editAction, deleteAction]
            )
        }
    }

    // MARK: - Show Delete Confirmation Alert
    private func showDeleteConfirmationAlert() {
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
        ) { _ in
            self.presenter?.deleteTracker(at: self.indexPath)
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
            popoverController.sourceView = viewController?.view
            popoverController.sourceRect = CGRect(
                x: viewController?.view.bounds.midX ?? 0,
                y: viewController?.view.bounds.midY ?? 0,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        viewController?.present(alertController, animated: true, completion: nil)
    }
}
