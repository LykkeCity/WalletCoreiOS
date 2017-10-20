//
//  UIView+Rx.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/29/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    var isHiddenAnimated: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { button, value in
            let alpha = CGFloat(value ? 0.0 : 1.0)
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveLinear, .allowUserInteraction, .beginFromCurrentState],
                animations: {button.alpha = alpha}
            ) { _ in
                button.isHidden = value
            }
        }
    }
}

