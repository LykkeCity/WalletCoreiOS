//
//  EmailCodeVerifyViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class EmailCodeVerifyViewModel {
    
    // IN:
    /// Trigger to call for networking
    public let checkCodeTrigger = PublishSubject<Void>()
    
    /// Store the email code to be verified
    public let codeInputSubject = PublishSubject<String>()
    
    // OUT:
    /// Called when encoded private key is fetched
    public let encodedPrivateKeySuccess: Observable<Void>
    
    /// Loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Errors occured
    public let errors: Observable<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(email: String, accessToken: String?, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let verifyEmailCodeRequest = checkCodeTrigger.asObservable()
            .withLatestFrom(codeInputSubject.asObservable())
            .flatMapLatest { authManager.emailCodeVerify.request(withParams: (email: email, code: $0, accessToken: accessToken)) }
            .shareReplay(1)
        
        let emailCodeSuccess = verifyEmailCodeRequest
            .filterSuccess()
            .shareReplay(1)
        
        let encodedPrivateKeyRequest = emailCodeSuccess
            .filter { $0.isPassed }
            .flatMapLatest { _ in authManager.getEncodedPrivateKey.request(withParams: accessToken) }
            .shareReplay(1)

        let emailCodeFailed = emailCodeSuccess
            .filter { !$0.isPassed }
            .flatMapLatest { _ in Observable<[AnyHashable : Any]>.just(["Message": "Wrong email code."]) }
            .shareReplay(1)
        
        encodedPrivateKeySuccess = encodedPrivateKeyRequest
            .filterSuccess()
            .map { _ in () }
        
        self.loadingViewModel = LoadingViewModel([
            verifyEmailCodeRequest.isLoading(),
            encodedPrivateKeyRequest.isLoading()
        ])
        
        self.errors = Observable.merge([
            emailCodeFailed,
            verifyEmailCodeRequest.filterError(),
            encodedPrivateKeyRequest.filterError()
        ])
    }
}
