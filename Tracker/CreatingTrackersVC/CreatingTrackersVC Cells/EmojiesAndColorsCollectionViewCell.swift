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
    
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 7
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
        contentView.layer.cornerRadius = 10
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(
        with element: String,
        isEmoji: Bool,
        isSelected: Bool,
        hasSelectedItem: Bool) {
            
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if isEmoji {
                emojiLabel.text = element
                colorView.isHidden = true
                contentView.backgroundColor = isSelected ? .ypLightGray : .clear
            } else {
                emojiLabel.text = ""
                colorView.isHidden = false
                colorView.backgroundColor = UIColor(hex: element)
                contentView.layer.borderWidth = isSelected ? 3 : 0
                contentView.layer.borderColor = isSelected ? UIColor(hex: element)?.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
            }
            //contentView.alpha = hasSelectedItem ? (isSelected ? 1.0 : 0.2) : 1.0
        }
    }
}
