//
//  ValidatePasswordViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ValidatePasswordViewModel {
    
    // IN:
    /// Password
    public let password = Variable<String>("")
    
    /// Repeat password
    public let repeatPassword = Variable<String>("")
    
    // OUT:
    /// Validity of the passwords
    public let arePasswordsValid: Observable<Bool>
    
    private let disposeBag = DisposeBag()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        self.arePasswordsValid = Observable.combineLatest(password.asObservable(), repeatPassword.asObservable()) { (password: $0, repeat: $1) }
            .map { $0.password.count > 5 && $0.repeat.count > 5 && $0.password == $0.repeat }
    }
}
