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
        dateLabelContainer.addSubview(counterLabel)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            counterLabel.leadingAnchor.constraint(equalTo: dateLabelContainer.leadingAnchor, constant: 8),
            counterLabel.trailingAnchor.constraint(equalTo: dateLabelContainer.trailingAnchor),
            counterLabel.topAnchor.constraint(equalTo: dateLabelContainer.topAnchor),
            counterLabel.bottomAnchor.constraint(equalTo: dateLabelContainer.bottomAnchor)
        ])
        
        let completeButtonContainer = UIView()
        completeButtonContainer.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeButton.leadingAnchor.constraint(equalTo: completeButtonContainer.leadingAnchor),
            completeButton.trailingAnchor.constraint(equalTo: completeButtonContainer.trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: completeButtonContainer.topAnchor),
            completeButton.bottomAnchor.constraint(equalTo: completeButtonContainer.bottomAnchor)
        ])
        
        let stack = UIStackView(arrangedSubviews: [
            dateLabelContainer,
            completeButtonContainer
        ])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private lazy var counterLabel: UILabel = {
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
    
    func configure(with tracker: Tracker, 
                   countComplete: Set<TrackerRecord>,
                   isCompleted: Bool,
                   isDateValidForCompletion: Bool) {
        if case .tracker(_, let name, let color, let emoji, let date) = tracker {
            nameLabel.text = name
            self.emoji.text = emoji
            messageStack.backgroundColor = color
            completeButton.backgroundColor = color
            
            let buttonImage = isCompleted ? "checkmark" : "plus"
            let buttonColor = isCompleted ? color.withAlphaComponent(0.3) : color
            completeButton.setImage(UIImage(systemName: buttonImage), for: .normal)
            completeButton.backgroundColor = buttonColor
            completeButton.isEnabled = isDateValidForCompletion
            
            let countDays = countComplete.count
            var day = ""
            
            if countDays == 1 {
                day = "День"
            } else if (2...4).contains(countDays) {
                day = "Дня"
            } else {
                day = "Дней"
            }
            counterLabel.text = ("\(countDays) \(day)")
            
            switch date { // надо подумать как прикрутить dates и надо ли!
            case .dates(let dates):
               print(dates)
            }
        }
    }
}
