//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 04.09.2024.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    private let onboardingStatus = OnboardingStatus()
    
    private lazy var backgroundImage = UIImageView()
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(
            ofSize: 32,
            weight: .bold
        )
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var button: UIButton = {
        return UIButton(
            title: LocalizationKey.onboardingButton.localized(),
            backgroundColor: .ypBlack,
            titleColor: .ypBackground,
            cornerRadius: 20,
            font: UIFont.systemFont(
                ofSize: 16,
                weight: .medium
            ),
            target: self,
            action: #selector(buttonAction)
        )
    }()
    
    init(with content: OnboardingHelper) {
        super.init(nibName: nil, bundle: nil)
        
        backgroundImage.image = content.image
        label.text = content.greeting
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        [backgroundImage,
         label,
         button
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func buttonAction() {
        onboardingStatus.setOnboardingSeen()
        
        guard let window = UIApplication.shared.windows.first else { return }
        
        let mainViewController = LaunchViewController()
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }
}
