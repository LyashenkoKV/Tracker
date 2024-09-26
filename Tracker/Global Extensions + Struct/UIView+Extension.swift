//
//  UIView + Extension.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 12.08.2024.
//

import UIKit

extension UIView {
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: type)
    }
}
