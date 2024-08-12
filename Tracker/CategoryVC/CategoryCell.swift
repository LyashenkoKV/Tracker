//
//  CategoryCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

final class CategoryCell: CategoryBaseCell {
    static let reuseIdentifier = "CategoryCell"
    
    override func configure(with text: String, showSwitch: Bool = false) {
        super.configure(with: text, showSwitch: false)
    }
}
