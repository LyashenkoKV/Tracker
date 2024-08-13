//
//  CreateTrackerCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

final class EmojiesAndColorsTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CollectionTableViewCell"
    
    private var selectedIndexPath: IndexPath?
    private var hasSelectedItem = false

    private let params = GeometricParams(
        cellCount: 6,
        leftInset: 10,
        rightInset: 10,
        cellSpacing: 17
    )
    
    private var elements: [String] = []
    private var isEmoji: Bool = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = params.cellSpacing
        layout.minimumInteritemSpacing = params.cellSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0, 
            left: params.leftInset,
            bottom: 0, 
            right: params.rightInset
        )
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(
            EmojiesAndColorsCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiesAndColorsCollectionViewCell.reuseIdentifier
        )
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with elements: [String], isEmoji: Bool) {
        self.elements = elements
        self.isEmoji = isEmoji
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension EmojiesAndColorsTableViewCell: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
            var selectedElement = ""
            
            if selectedIndexPath == indexPath {
                selectedIndexPath = nil
                hasSelectedItem = false
            } else {
                selectedIndexPath = indexPath
                hasSelectedItem = true
                selectedElement = elements[indexPath.item]
            }
            
            collectionView.reloadData()
            
            if isEmoji {
                NotificationCenter.default.post(
                    name: .emojiSelected,
                    object: nil,
                    userInfo: ["selectedEmoji": selectedElement]
                )
            } else {
                NotificationCenter.default.post(
                    name: .colorSelected,
                    object: nil,
                    userInfo: ["selectedColor": selectedElement]
                )
            }
        }
}

// MARK: - UICollectionViewDataSource
extension EmojiesAndColorsTableViewCell: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return elements.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiesAndColorsCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiesAndColorsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let element = elements[indexPath.item]
        let isSelected = indexPath == selectedIndexPath
        
        cell.configure(
            with: element,
            isEmoji: isEmoji,
            isSelected: isSelected,
            hasSelectedItem: hasSelectedItem
        )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EmojiesAndColorsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 10,
            left: params.leftInset,
            bottom: 10,
            right: params.rightInset
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth,
                      height: cellWidth)
    }
}
