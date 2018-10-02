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

public class PhoneCodeVerifyViewModel {
    
    // IN:
    /// Trigger to call for networking
    public let checkCodeTrigger = PublishSubject<Void>()
    
    /// Store the sms code to be verified
    public let codeInputSubject = PublishSubject<String>()
    
    // OUT:
    /// Called when sms code request is complete
    public let correctSmsCodeObservable: Observable<Void>
    
    /// Loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Errors occured
    public let errors: Observable<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let verifySmsCodeRequest = checkCodeTrigger.asObservable()
            .withLatestFrom(codeInputSubject.asObservable())
            .flatMapLatest { authManager.phoneCodeVerify.request(withParams: $0) }
            .shareReplay(1)
        
        self.correctSmsCodeObservable = verifySmsCodeRequest
            .filterSuccess()
            .map {_ in ()}
        
        self.loadingViewModel = LoadingViewModel([
            verifySmsCodeRequest.isLoading()
        ])
        
        self.errors = Observable.merge([
            verifySmsCodeRequest.filterError()
        ])
    }
}
