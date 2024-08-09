//
//  TextViewCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit
// MARK: - Protocol
protocol TextViewCellDelegate: AnyObject, UITextViewDelegate {
    func textViewCellDidBeginEditing(_ cell: TextViewCell)
    func textViewCellDidEndEditing(_ cell: TextViewCell, text: String?)
    func textViewCellDidChange(_ cell: TextViewCell)
}

// MARK: - Object
final class TextViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TextViewCell"
    
    weak var delegate: TextViewCellDelegate?
    
    private let placeholderText = "Введите название трекера"
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .lightGray
        textView.tintColor = .systemBlue
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 15
        textView.layer.masksToBounds = true
        textView.backgroundColor = .ypWhiteGray
        textView.textAlignment = .left
        textView.textContainerInset = UIEdgeInsets(top: 30, left: 16, bottom: 30, right: 16)
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        textView.delegate = self
        textView.text = placeholderText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func getText() -> UITextView {
        return textView
    }
}

// MARK: - Extension
extension TextViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = nil
            textView.textColor = .black
        }
        delegate?.textViewCellDidBeginEditing(self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
        delegate?.textViewCellDidEndEditing(self, text: textView.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewCellDidChange(self)
    }
}
