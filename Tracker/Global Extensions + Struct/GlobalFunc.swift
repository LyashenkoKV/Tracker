//
//  GlobalFunc.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 15.08.2024.
//

import UIKit

public func dismissKeyboard(view: UIView) {
    let tapGesture = UITapGestureRecognizer(
        target: view,
        action: #selector(UIView.endEditing(_:))
    )
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
}
