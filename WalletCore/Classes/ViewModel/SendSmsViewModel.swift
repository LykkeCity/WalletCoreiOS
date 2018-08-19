//
//  SendSmsViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class SendSmsViewModel {
    // IN:
    /// Send SMS trigger
    public let smsSendTrigger = Variable<Void>(())
    
    // OUT:
    /// Ownership message and private signature for that message
    public let outputRecoveryModel: Observable<LWRecoveryPasswordModel>
    
    /// Loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Errors occured
    public let errors: Observable<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(inputRecoveryModel: Observable<LWRecoveryPasswordModel>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let emailObservable = inputRecoveryModel
            .map { $0.email }
            .filter { $0.isNotEmpty }
        
        let privateKeyRequest = smsSendTrigger.asObservable()
            .withLatestFrom(emailObservable)
            .flatMapLatest { authManager.ownershipMessage.request(withParams: (email: $0, signature: ""))}
            .shareReplay(1)
        
        self.outputRecoveryModel = privateKeyRequest.filterSuccess()
            .withLatestFrom(inputRecoveryModel) { (result: $0, model: $1) }
            .map { value in
                value.model.securityMessage1 = value.result.ownershipMessage
                value.model.signature1 = LWPrivateKeyManager.shared().signatureForMessage(withLykkeKey: value.result.ownershipMessage)
                
                return value.model
            }
        
        self.loadingViewModel = LoadingViewModel([
            privateKeyRequest.isLoading()
        ])
        
        self.errors = Observable.merge([
            privateKeyRequest.filterError()
        ])
    }
}
