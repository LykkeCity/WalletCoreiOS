//
//  ConfirmSmsViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ConfirmSmsViewModel {
    
    // IN:
    /// Recovery data FOR sms confirmation
    public let inputRecoveryModel = PublishSubject<LWRecoveryPasswordModel>()
    
    // OUT:
    /// Recovery data AFTER sms confirmation
    public let outputRecoveryModel: Observable<LWRecoveryPasswordModel>
    
    /// Errors occured
    public let errors: Observable<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let recoverySmsRequest = inputRecoveryModel.asObservable()
            .flatMapLatest { authManager.recoverySmsConfirmation.request(withParams: $0) }
            .shareReplay(1)
        
        self.outputRecoveryModel = recoverySmsRequest.filterSuccess()
            .withLatestFrom(inputRecoveryModel) { (result: $0, model: $1) }
            .map { value in
                value.model.signature2 = LWPrivateKeyManager.shared().signatureForMessage(withLykkeKey: value.model.securityMessage2)
                
                return value.model
        }
        
        self.errors = Observable.merge([
            recoverySmsRequest.filterError()
        ])
    }
}
