//
//  ChangePasswordViewModel.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 6.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ChangePasswordViewModel {
    
    public let password = Variable<String>("")
    
    public let confirmPassword = Variable<String>("")
    
    public let pin = Variable<String>("")
    
    public let hint = Variable<String>("")
    
    public init(){}
    
    public lazy var isValid: Observable<Bool> = {
        return Observable.combineLatest( self.password.asObservable(), self.confirmPassword.asObservable(), self.hint.asObservable())
            { (password, confirmPassword, hint) -> Bool in
                return password.count > 5
                    && confirmPassword.count > 5
                    && self.password.value == self.confirmPassword.value
                    && hint.count > 2
        }
    }()
    
}
