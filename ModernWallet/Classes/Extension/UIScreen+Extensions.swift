//
//  UIScreen+Extensions.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 5.02.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import Foundation

extension UIScreen {
    
    /// Return if the screen is too small
    class var isSmallScreen: Bool {
        switch UIScreen.main.bounds.height {
        case 0...667:
            return true
        default:
            return false
        }
    }
}
