//
//  UITextField+PlaceholderColor.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 10/10/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return nil
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}
