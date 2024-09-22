//
//  GradientBorderView.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 22.09.2024.
//

import UIKit

final class GradientBorderView: UIView {
    var gradientColors: [UIColor] = [.systemRed, .systemBlue] {
        didSet {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let gradient = UIImage.gradientImage(bounds: bounds, colors: gradientColors)
        layer.borderColor = UIColor(patternImage: gradient).cgColor
    }
}
