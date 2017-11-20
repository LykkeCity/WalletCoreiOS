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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBorder()
    }
    
    private func setupBorder() {
        borderColor = buttonBorderColor
        borderWidth = 1.0
        setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5995023545), for: .disabled)
    }

    override var isEnabled: Bool {
        didSet {
            borderColor = buttonBorderColor
        }
    }
    
    private var buttonBorderColor: UIColor {
        return isEnabled ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5995023545)
    }

}
