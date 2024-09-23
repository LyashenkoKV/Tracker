//
//  UIButton + Extensions.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

extension UIButton {
    
    convenience init(
        title: String,
        backgroundColor: UIColor,
        titleColor: UIColor,
        cornerRadius: CGFloat,
        font: UIFont,
        target: Any?,
        action: Selector) {
        self.init()
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius
        self.addTarget(target, action: action, for: .touchUpInside)
    }
}
