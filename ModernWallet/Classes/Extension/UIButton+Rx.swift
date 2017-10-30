//
//  UIButton+Rx.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UIButton {
    
    var title: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { button, value in
            button.setTitle(value, for: UIControlState.normal)
        }
    }
    
    var borderColor: UIBindingObserver<Base, UIColor> {
        return UIBindingObserver(UIElement: self.base) { button, color in
            button.borderColor = color
        }
    }
    
    var isEanbledWithBorderColor: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { button, value in
            button.isEnabled = value
            button.borderColor = value ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.3031407299)
        }
    }
}

