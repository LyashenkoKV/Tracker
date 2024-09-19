//
//  BaseCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 11.08.2024.
//

import UIKit

class CategoryBaseCell: UITableViewCell {
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(
            ofSize: 17,
            weight: .regular
        )
        return label
    }()
    
    let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.isHidden = true
        toggleSwitch.onTintColor = .ypBlue
        return toggleSwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(categoryLabel)
        contentView.addSubview(toggleSwitch)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -27),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with text: String, showSwitch: Bool = false, isSwitchOn: Bool = false) {
        categoryLabel.text = text
        toggleSwitch.isHidden = !showSwitch
        toggleSwitch.isOn = isSwitchOn
    }
}
