//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 30.07.2024.
//

import UIKit

protocol TrackersPresenterProtocol {
    var view: TrackersViewControllerProtocol? { get set }
    var dateFormatter: DateFormatter { get }
    func viewDidLoad()
    func addTracker(_ tracker: Tracker, categotyTitle: String)
    func trackerCompletedMark(_ trackerId: UUID, date: String)
    func trackerCompletedUnmark(_ trackerId: UUID, date: String)
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool)
}

final class TrackersPresenter {
    weak var view: TrackersViewControllerProtocol?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    init(view: TrackersViewControllerProtocol) {
        self.view = view
    }
}

extension TrackersPresenter: TrackersPresenterProtocol {
    
    func viewDidLoad() {
        
    }
    
    func addTracker(_ tracker: Tracker, categotyTitle: String) {
        var newCategories: [TrackerCategory] = []
        var categoryExists = false
        
        for category in view?.categories ?? [] {
            if case .category(let title, var trackers) = category, title == categotyTitle {
                trackers.append(tracker)
                newCategories.append(.category(title: title, trackers: trackers))
                categoryExists = true
            } else {
                newCategories.append(category)
            }
        }
        if !categoryExists {
            newCategories.append(.category(title: categotyTitle, trackers: [tracker]))
        }
        view?.categories = newCategories
        
        DispatchQueue.main.async { [ weak self ] in
            guard let self else { return }
            if let vc = self.view as? TrackersViewController {
                vc.reloadData()
                vc.updatePlaceholderView()
            }
        }
    }
    
    func trackerCompletedMark(_ trackerId: UUID, date: String) {
        guard let view = view else { return }
        if !isTrackerCompleted(trackerId, date: date) {
            view.completedTrackers.append(.record(trackerId: trackerId, date: date))
            view.reloadData()
        }
    }
    
    func trackerCompletedUnmark(_ trackerId: UUID, date: String) {
        guard let view = view else { return }
        if let index = view.completedTrackers.firstIndex(where: {
            if case .record(let id, let recordDate) = $0 {
                return id == trackerId && recordDate == date
            }
            return false
        }) {
            view.completedTrackers.remove(at: index)
            view.reloadData()
        }
    }
    
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool {
        guard let view = view else { return false }
        return view.completedTrackers.contains(where: {
            if case .record(let id, let recordDate) = $0 {
                return id == trackerId && recordDate == date
            }
            return false
        })
    }
    
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool) {
        var trackerId: UUID?
        if case .tracker(let id, _, _, _, _) = tracker {
            trackerId = id
        }
        
        guard let id = trackerId else { return }
        
        let currentDateString = dateFormatter.string(from: view?.currentDate ?? Date())
        
        if isCompleted {
            trackerCompletedUnmark(id, date: currentDateString)
        } else {
            trackerCompletedMark(id, date: currentDateString)
        }
        view?.reloadData()
    }
}
