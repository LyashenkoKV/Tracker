//
//  CategoryCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

//final class CategoryCell: UITableViewCell {
//    static let reuseIdentifier = "CategoryCell"
//    
//    private let categoryLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .left
//        label.font = UIFont.systemFont(ofSize: 17)
//        return label
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        contentView.addSubview(categoryLabel)
//        contentView.backgroundColor = .clear
//        contentView.layer.cornerRadius = 10
//        NSLayoutConstraint.activate([
//            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
//            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -27),
//            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//        ])
//    }
//    
//    func configure(with text: String) {
//        self.categoryLabel.text = text
//    }
//}

final class CategoryCell: CategoryBaseCell {
    static let reuseIdentifier = "CategoryCell"
    
    override func configure(with text: String, showSwitch: Bool = false) {
        super.configure(with: text, showSwitch: false)
    }
}
