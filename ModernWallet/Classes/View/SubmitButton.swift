//
//  SubmitButton.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 20.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

@IBDesignable
class SubmitButton: UIButton {
    
    private var normalColor: UIColor {
        return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    private var disabledColor: UIColor {
        return normalColor.withAlphaComponent(0.6)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBorder()
    }
    
    override func prepareForInterfaceBuilder() {
        titleLabel?.font = UIFont(name: "Geomanist-Book", size: 20.0)
    }
    
    private func setupBorder() {
        titleLabel?.font = UIFont(name: "Geomanist-Book", size: 20.0)
        borderWidth = 1.0
        updateColors()
    }

    override var isEnabled: Bool {
        didSet {
            borderColor = buttonBorderColor
        }
    }
    
    private var buttonBorderColor: UIColor {
        return isEnabled ? normalColor : disabledColor
    }
    
    private func updateColors() {
        borderColor = buttonBorderColor
        setTitleColor(normalColor, for: .normal)
        setTitleColor(disabledColor, for: .disabled)
    }

}
