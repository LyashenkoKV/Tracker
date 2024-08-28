//
//  CollectionViewCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

final class EmojiesAndColorsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CollectionViewCell"

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [emojiLabel, colorView].forEach {
            contentView.addSubview($0)
        }
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 15
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7)
        ])
    }
    
    func configure(
        with element: String,
        isEmoji: Bool,
        isSelected: Bool,
        hasSelectedItem: Bool) {

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            contentView.layer.borderWidth = 0
            contentView.backgroundColor = .clear
            emojiLabel.text = ""
            colorView.backgroundColor = .clear
            
            if isEmoji {
                emojiLabel.text = element
                colorView.isHidden = true
                contentView.backgroundColor = isSelected ? .ypLightGray : .clear
            } else {
                colorView.isHidden = false
                colorView.backgroundColor = UIColor(hex: element)
                if isSelected {
                    contentView.layer.borderWidth = 4
                    contentView.layer.borderColor = UIColor(hex: element)?.withAlphaComponent(0.3).cgColor
                }
            }
            //contentView.alpha = hasSelectedItem ? (isSelected ? 1.0 : 0.2) : 1.0
        }
    }

}
