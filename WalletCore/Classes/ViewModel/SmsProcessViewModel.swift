//
//  SmsProcessViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class SmsProcessViewModel {
    // IN:
    public let smsTrigger = Variable<Void>(())
    public let email = Variable<String>("")
    
    // OUT:
    public var loadingViewModel: LoadingViewModel
    
    public init(email: Variable<String>, signedOwnershipMessage: Variable<String>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let requestParams = Observable.combineLatest(email.asObservable(), signedOwnershipMessage.asObservable())
        { (email: $0, signature: $1) }
        
        
        let smsSendRequest = smsTrigger.asObservable()
            .withLatestFrom(requestParams.debug("smsTrigger: "))
            .flatMapLatest { authManager.recoverySmsConfirmation.request(withParams: $0) }
            .shareReplay(1)
        
        smsSendRequest.filterSuccess()
            .subscribe(onNext: { value in
                print("phone is: \(value.recModel.phoneNumber)")
                print("security message is: \(value.recModel.securityMessage2) ")
                
            })
        
        self.loadingViewModel = LoadingViewModel([
            smsSendRequest.isLoading()
            ])
    }
}
