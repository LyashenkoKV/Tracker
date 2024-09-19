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
    private var completedTrackers: Set<TrackerRecord>
    
    // MARK: - Init
    init(
        tracker: Tracker,
        indexPath: IndexPath,
        presenter: TrackersPresenterProtocol?,
        viewController: UIViewController?,
        completedTrackers: Set<TrackerRecord>
    ) {
        self.tracker = tracker
        self.indexPath = indexPath
        self.presenter = presenter
        self.viewController = viewController
        self.completedTrackers = completedTrackers
    }

    // MARK: - Create Context Menu
    func createContextMenu() -> UIMenu {
        let pinTitle = self.tracker.isPinned
            ? NSLocalizedString("unpin", comment: "Открепить")
            : NSLocalizedString("pin", comment: "Закрепить")
        
        let pinAction = UIAction(
            title: pinTitle
        ) { [weak self] _ in
            guard let self else { return }
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
            self.showEditTrackerView()
        }
        
        return UIMenu(
            title: "",
            children: [pinAction, editAction, deleteAction]
        )
    }
    
    // MARK: - Show Edit Tracker View
    private func showEditTrackerView() {
        let creatingTrackerVC = CreatingTrackerViewController(
            type: .creatingTracker,
            isRegularEvent: tracker.isRegularEvent
        )
        creatingTrackerVC.trackerToEdit = tracker
        creatingTrackerVC.completedTrackers = completedTrackers
        creatingTrackerVC.title = NSLocalizedString(
            "edit_tracker",
            comment: "Редактирование привычки"
        )
        let navController = UINavigationController(rootViewController: creatingTrackerVC)
        navController.modalPresentationStyle = .formSheet
        viewController?.present(navController, animated: true)
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
