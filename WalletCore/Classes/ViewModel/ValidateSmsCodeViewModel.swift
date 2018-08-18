//
//  ValidateSmsCodeViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ValidateSmsCodeViewModel {
    
    // IN:
    /// Sms code received
    public let smsCode = Variable<String>("")
    
    // OUT:
    /// Validity of the smsCode
    public let isSmsCodeValid: Observable<Bool>
    
    private let disposeBag = DisposeBag()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        self.isSmsCodeValid = smsCode.asObservable()
            .map { $0.count >= 4 }
    }
}
