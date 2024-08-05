//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 26.07.2024.
//

import UIKit

final class TrackersCardCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackersCell"
    
    var selectButtonTappedHandler: (() -> Void)?
    
    private lazy var mainVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            messageStack,
            horizontalStack
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var messageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            emoji,
            nameLabel
        ])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.layer.cornerRadius = 15
        stack.layer.masksToBounds = true
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 10, right: 12)
        stack.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return stack
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 0
        return label
    }()
    
    private let emoji: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.backgroundColor = .systemBackground.withAlphaComponent(0.3)
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 24).isActive = true
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return label
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: 5).isActive = true
        
        let dateLabelContainer = UIView()
        dateLabelContainer.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: dateLabelContainer.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: dateLabelContainer.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: dateLabelContainer.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: dateLabelContainer.bottomAnchor)
        ])
        
        let selectButtonContainer = UIView()
        selectButtonContainer.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeButton.leadingAnchor.constraint(equalTo: selectButtonContainer.leadingAnchor),
            completeButton.trailingAnchor.constraint(equalTo: selectButtonContainer.trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: selectButtonContainer.topAnchor),
            completeButton.bottomAnchor.constraint(equalTo: selectButtonContainer.bottomAnchor)
        ])
        
        let stack = UIStackView(arrangedSubviews: [
            dateLabelContainer,
            selectButtonContainer
        ])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypWhite
        button.widthAnchor.constraint(equalToConstant: 34).isActive = true
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        contentView.addSubview(mainVerticalStack)
        mainVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainVerticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainVerticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainVerticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainVerticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    @objc private func completeButtonTapped() {
        selectButtonTappedHandler?()
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool) {
        if case .tracker(_, let name, let color, let emoji, let date) = tracker {
            nameLabel.text = name
            self.emoji.text = emoji
            messageStack.backgroundColor = color
            completeButton.backgroundColor = color
            
            let buttonImageName = isCompleted ? "checkmark" : "plus"
            let buttonColor = isCompleted ? color.withAlphaComponent(0.3) : color
            completeButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
            completeButton.backgroundColor = buttonColor
            
            switch date {
            case .dates(let dates):
                let countDays = dates.count
                var day = ""
                
                if (1...3).contains(countDays) {
                    day = "День"
                } else if countDays == 4 {
                    day = "Дня"
                } else {
                    day = "Дней"
                }
                dateLabel.text = ("\(countDays) \(day)")
            }
        }
    }
}
