//
//  StatisticCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 10.09.2024.
//

import UIKit

final class StatisticCell: UICollectionViewCell {
    static let reuseIdentifier = "StatisticCell"
    
    private let borderView: GradientBorderView = {
        let view = GradientBorderView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.textAlignment = .left
        label.textColor = .ypBlack
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 12,
            weight: .medium
        )
        label.textAlignment = .left
        label.textColor = .ypBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(borderView)
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        borderView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor)
        ])
    }
    
    func configure(with value: String, title: String, gradientColors: [UIColor]) {
        valueLabel.text = value
        titleLabel.text = title
        
        borderView.gradientColors = gradientColors
    }
}
