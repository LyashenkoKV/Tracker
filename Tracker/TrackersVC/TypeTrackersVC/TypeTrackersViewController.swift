//
//  TypeTrackersViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

final class TypeTrackersViewController: UIViewController {
    
    private func addNewButton(with title: String, action: Selector) -> UIButton {
        return UIButton(
            title: title,
            backgroundColor: .ypBlack,
            titleColor: .ypWhite,
            cornerRadius: 20,
            font: UIFont.systemFont(ofSize: 16),
            target: self,
            action: action
        )
    }
    
    private lazy var habitButton = addNewButton(
        with: "Привычка",
        action: #selector(createNewTracker)
    )
    private lazy var irregularEventButton = addNewButton(
        with: "Нерегулярное событие",
        action: #selector(createNewTracker)
    )
    
    private lazy var stackButtons: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
        habitButton,
        irregularEventButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
// MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupLayout()
        self.title = "Создание трекера"
    }
    
    private func setupLayout() {
        [habitButton, irregularEventButton, stackButtons].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [stackButtons].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackButtons.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func createNewTracker() {
        let newTrackersVC = CreatingTrackerViewController(title: "Новая привычка")
        let navController = UINavigationController(rootViewController: newTrackersVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true, completion: nil)
    }
}
