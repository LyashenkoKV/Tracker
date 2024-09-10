//
//  StatisticCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 10.09.2024.
//

import UIKit

final class StatisticCell: UICollectionViewCell {
    static let reuseIdentifier = "StatisticCell"
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
        ]
        return gradientLayer
    }()
    
    private let borderLayer: CALayer = {
        let borderLayer = CALayer()
        borderLayer.borderWidth = 2
        borderLayer.cornerRadius = 8
        borderLayer.masksToBounds = true
        return borderLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.layer.addSublayer(borderLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = containerView.bounds
        borderLayer.frame = containerView.bounds
        borderLayer.borderWidth = 2
        borderLayer.cornerRadius = 8
    }
    
    func configure(with value: String, title: String, colors: [UIColor]) {
        valueLabel.text = value
        titleLabel.text = title
        
        gradientLayer.colors = colors.map { $0.cgColor }
    }
}
