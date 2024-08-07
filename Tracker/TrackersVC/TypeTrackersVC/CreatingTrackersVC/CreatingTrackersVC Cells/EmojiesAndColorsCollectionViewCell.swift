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
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with element: String, isEmoji: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if isEmoji {
                self.emojiLabel.text = element
                contentView.backgroundColor = .clear
            } else {
                self.emojiLabel.text = ""
                contentView.backgroundColor = UIColor(hex: element)
            }
        }
    }
}

