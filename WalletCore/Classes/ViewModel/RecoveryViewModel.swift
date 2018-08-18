//
//  RecoveryViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class RecoveryViewModel {
    
    // IN:
    public let email = Variable<String>("")
    public let password = Variable<String>("")
    public let hint = Variable<String>("")
    public let smsCode = Variable<String>("")
    public let pin = Variable<String>("")
    public let signature = Variable<String>("")

    public let changeTrigger = PublishSubject<Void>()
    
    // OUT:
    public var recoveryData: Observable<LWRecoveryPasswordModel>
    
    // Triggered when the pin and password are changed
    public let didChangePinAndPassword: Observable<Void>
    
    // Loading
    public var loadingViewModel: LoadingViewModel
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        self.recoveryData = Observable.combineLatest(
            self.email.asObservable(),
            self.password.asObservable(),
            self.hint.asObservable(),
            self.smsCode.asObservable(),
            self.pin.asObservable(),
            self.signature.asObservable()
        ) {
            let model = LWRecoveryPasswordModel()
            model.email = $0
            model.password = $1
            model.hint = $2
            model.smsCode = $3
            model.pin = $4
            model.signature2 = $5
            return model
        }
        
        let changeRequest = changeTrigger.asObservable()
            .withLatestFrom(recoveryData)
            .flatMapLatest { authManager.changePinAndPassword.request(withParams: $0) }
            .shareReplay(1)
        
        self.didChangePinAndPassword = changeRequest.filterSuccess()
            .map { _ in return () }
        
        self.loadingViewModel = LoadingViewModel([
            changeRequest.isLoading()
        ])
    }
}
