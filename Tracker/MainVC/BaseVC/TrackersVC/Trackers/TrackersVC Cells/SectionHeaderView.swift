//
//  SectionHeaderView.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 01.08.2024.
//

import UIKit

final class SectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "header"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(
            ofSize: 19,
            weight: .bold
        )
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTitle(_ title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = title
        }
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
