//
//  UIViewController+Loading.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import RxCocoa
import RxSwift
import SwiftSpinner

extension Reactive where Base: UIViewController {
    
    var loading: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { vc, value in
            
            SwiftSpinner.useContainerView(UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first)
            
            guard value else {
                SwiftSpinner.hide()
                return
            }
            
            SwiftSpinner.show("Loading...")
        }
    }
}
