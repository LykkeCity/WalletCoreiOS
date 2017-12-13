//
//  UIView+Extensions.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 12.12.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

extension UIView {
    
    func setShadow(radius: CGFloat, color: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), opacity: Float = 1.0, offset: CGSize = .zero) {
        let viewLayer = self.layer
        viewLayer.shadowRadius = radius
        viewLayer.shadowColor = color
        viewLayer.shadowOpacity = opacity
        viewLayer.shadowOffset = offset
    }
    
}
