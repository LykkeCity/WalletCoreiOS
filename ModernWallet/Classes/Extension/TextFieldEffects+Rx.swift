//
//  TextFieldEffects+Rx.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import TextFieldEffects
import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: HoshiTextField {
    
    var error: UIBindingObserver<HoshiTextField, Bool> {
        return UIBindingObserver(UIElement: self.base) { field, value in
            
            let borderColor = value ? UIColor.red : UIColor.clear
            field.borderInactiveColor = borderColor
            field.borderActiveColor = borderColor
            
            field.placeholderColor = value ? UIColor.red : UIColor.white
        }
    }
}

