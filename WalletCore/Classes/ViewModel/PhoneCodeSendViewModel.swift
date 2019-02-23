//
//  PhoneCodeSendViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class PhoneCodeSendViewModel {
    
    // IN:
    /// Trigger to call for networking
    public let sendSmsCodeTrigger = BehaviorSubject<Void>(value: ())
    
    // OUT:
    /// Called when sms code request is complete
    public let sendSmsCodeComplete: Observable<Void>
    
    /// Loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Errors occured
    public let errors: Observable<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let sendSmsCodeRequest = sendSmsCodeTrigger.asObservable()
            .flatMapLatest { authManager.phoneCodeSend.request() }
            .shareReplay(1)
        
        self.sendSmsCodeComplete = sendSmsCodeRequest
            .filterSuccess()
            .map {_ in ()}
        
        self.loadingViewModel = LoadingViewModel([
            sendSmsCodeRequest.isLoading()
        ])
        
        self.errors = Observable.merge([
            sendSmsCodeRequest.filterError()
        ])
    }
}
