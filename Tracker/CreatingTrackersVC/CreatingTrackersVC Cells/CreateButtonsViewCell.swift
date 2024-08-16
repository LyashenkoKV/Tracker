//
//  CreateButtonsViewCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

final class CreateButtonsViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CreateButtonsCell"
    
    var onCreateButtonTapped: (() -> Void)?
    var onCancelButtonTapped: (() -> Void)?
    
    private lazy var createButton: UIButton = {
        let button = addButton(
            with: "Создать",
            backgroundColor: .ypGray,
            titleColor: .ypWhite,
            action: #selector(createButtonAction)
        )
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = addButton(
            with: "Отменить",
            backgroundColor: .clear,
            titleColor: .ypRed,
            action: #selector(cancelButtonAction)
        )
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            cancelButton,
            createButton
        ])
        stack.axis = .horizontal
        stack.backgroundColor = .clear
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [createButton, cancelButton, buttonStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func addButton(
        with title: String,
        backgroundColor: UIColor,
        titleColor: UIColor,
        action: Selector
    ) -> UIButton {
        let button = UIButton()
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 15
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func createButtonAction() {
        onCreateButtonTapped?()
    }
    
    @objc private func cancelButtonAction() {
        onCancelButtonTapped?()
    }
    
    func updateCreateButtonState(isEnabled: Bool) {
        if isEnabled {
            createButton.backgroundColor = .ypBlack
            createButton.isUserInteractionEnabled = true
        } else {
            createButton.backgroundColor = .ypGray
        }
    }
}
