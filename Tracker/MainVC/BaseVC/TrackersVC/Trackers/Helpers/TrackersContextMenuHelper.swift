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
        ? LocalizationKey.unpin.localized()
        : LocalizationKey.pin.localized()
        
        let pinAction = UIAction(
            title: pinTitle
        ) { [weak self] _ in
            guard let self else { return }
            self.presenter?.togglePin(for: self.tracker)
        }

        let deleteAction = UIAction(
            title: LocalizationKey.delete.localized(),
            attributes: .destructive
        ) { _ in
            self.presenter?.logEvent(event: "click", screen: "TrackersVC", item: "delete")
            self.showDeleteConfirmationAlert()
        }

        let editAction = UIAction(
            title: LocalizationKey.edit.localized()
        ) { _ in
            self.presenter?.logEvent(event: "click", screen: "TrackersVC", item: "edit")
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

        let navController = UINavigationController(rootViewController: creatingTrackerVC)
        navController.modalPresentationStyle = .formSheet
        viewController?.present(navController, animated: true)
    }
    
    // MARK: - Show Delete Confirmation Alert
    private func showDeleteConfirmationAlert() {
        let alertController = UIAlertController(
            title: LocalizationKey.deleteConfirmationMessage.localized(),
            message: nil,
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(
            title: LocalizationKey.delete.localized(),
            style: .destructive
        ) { _ in
            self.presenter?.deleteTracker(at: self.indexPath)
        }

        let cancelAction = UIAlertAction(
            title: LocalizationKey.alertCancel.localized(),
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
