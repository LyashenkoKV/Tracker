//
//  Placeholder.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

struct Placeholder {
    
    let view: UIView
    let imageView: UIImageView
    let label: UILabel
    
    init(image: UIImage?, text: String) {
        view = UIView()
        view.isHidden = true
        
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size.height = 80
        imageView.frame.size.width = 80
        
        label = UILabel()
        label.text = text
        label.font = .systemFont(
            ofSize: 12,
            weight: .medium
        )
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func update(image: UIImage, text: String) {
        label.text = text
        imageView.image = image
    }
}

enum PHName: String, CaseIterable {
    case trackersPH = "TrackersPH"
    case statisticPH = "StatisticPH"
    case searchPH = "SearchPH"
}
