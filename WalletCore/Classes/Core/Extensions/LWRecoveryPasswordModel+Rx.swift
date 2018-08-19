//
//  LWRecoveryPasswordModel+Rx.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 18.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: LWRecoveryPasswordModel {
    /// Bind the `email` property
    public var email: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, email in
            model.email = email
        }
    }
    
    /// Bind the `password` property
    public var password: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, password in
            model.password = password
        }
    }
    
    /// Bind the `hint` property
    public var hint: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, hint in
            model.hint = hint
        }
    }
    
    /// Bind the `smsCode` property
    public var smsCode: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, smsCode in
            model.smsCode = smsCode
        }
    }
    
    /// Bind the `pin` property
    public var pin: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, pin in
            model.pin = pin
        }
    }
    
    /// Bind the `securityMessage1` property
    public var securityMessage1: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, securityMessage1 in
            model.securityMessage1 = securityMessage1
        }
    }
    
    /// Bind the `securityMessage2` property
    public var securityMessage2: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, securityMessage2 in
            model.securityMessage2 = securityMessage2
        }
    }
    
    /// Bind the `signature1` property
    public var signature1: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, signature1 in
            model.signature1 = signature1
        }
    }
    
    /// Bind the `signature2` property
    public var signature2: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { model, signature2 in
            model.signature2 = signature2
        }
    }
}
