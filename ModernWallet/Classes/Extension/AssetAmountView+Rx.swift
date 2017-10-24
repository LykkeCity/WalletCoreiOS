//
//  AssetAmountView+Rx.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 23.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WalletCore

extension Reactive where Base: AssetAmountView {
    
    var amount: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: self.base) { amountView, value in
            
            amountView.amount = value
        }
    }
    
    var code: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: self.base) { amountView, value in
            
            amountView.code = value
        }
    }
    
}
