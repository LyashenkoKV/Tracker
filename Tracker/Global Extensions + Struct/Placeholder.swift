//
//  Placeholder.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

final class Placeholder: UIView {
    
    private let imageView: UIImageView
    private let label: UILabel
    
    init(image: UIImage?, text: String) {
        imageView = UIImageView(image: image)
        label = UILabel()
        
        super.init(frame: .zero)
        
        configureView(text: text)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView(text: String) {
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size.height = 80
        imageView.frame.size.width = 80
        
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
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
