//
//  CreateTrackerCell.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 06.08.2024.
//

import UIKit

final class CollectionTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CollectionTableViewCell"
    
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
        layout.sectionInset = UIEdgeInsets(top: 0, left: params.leftInset, bottom: 0, right: params.rightInset)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.reuseIdentifier)
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
extension CollectionTableViewCell: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension CollectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseIdentifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        let element = elements[indexPath.item]
        cell.configure(with: element, isEmoji: isEmoji)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionTableViewCell: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let paddingSpace = params.cellSpacing * (CGFloat(params.cellCount) + 1)
//        let availableWidth = collectionView.frame.width - paddingSpace
//        let widthPerItem = availableWidth / CGFloat(params.cellCount)
//        return CGSize(width: widthPerItem, height: widthPerItem)
//    }
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
//        let availableWidth = collectionView.frame.width - params.paddingWidth
//        print("\(collectionView.frame.width) - \(params.paddingWidth) = \(availableWidth)")
//        let cellWidth =  availableWidth / CGFloat(params.cellCount)
//        print("\(availableWidth) / \(CGFloat(params.cellCount)) = \(cellWidth)")
//        let height: CGFloat
//        // Рассчитаем высоту.
//        if indexPath.row % 6 < 2 {
//            print("\(indexPath.row % 6 < 2)")
//            height = 2 / 3
//        } else {
//            height = 1 / 3
//        }
//        return CGSize(width: cellWidth,
//                      height: cellWidth * height)
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth,
                      height: cellWidth)
    }
    
}
