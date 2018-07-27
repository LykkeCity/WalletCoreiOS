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
    
    func pinToSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["pinnedView": self]
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "|[pinnedView]|",
                                                        options: .alignAllCenterY,
                                                        metrics: nil,
                                                        views: views)
        NSLayoutConstraint.activate(horizontal)
        
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[pinnedView]|",
                                                      options: .alignAllCenterX,
                                                      metrics: nil, views: views)
        NSLayoutConstraint.activate(vertical)
    }
    
    func loadViewFromNib(_ nibName: String) -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func cornerRadius(heightPercent: CGFloat) {
        layer.cornerRadius = layer.bounds.height * heightPercent
    }
}
