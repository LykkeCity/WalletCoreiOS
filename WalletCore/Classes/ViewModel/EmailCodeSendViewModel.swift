//
//  EmailCodeSendViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class EmailCodeSendViewModel {
    
    // IN:
    /// Trigger to call for networking
    public let sendEmailCodeTrigger = BehaviorSubject<Void>(value: ())
    
    // OUT:
    /// Called when email code request is complete
    public let sendEmailCodeComplete: Observable<Void>
    
    /// Loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Errors occured
    public let errors: Observable<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(email: String, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let sendEmailCodeRequest = sendEmailCodeTrigger.asObservable()
            .flatMapLatest { authManager.emailCodeSend.request(withParams: email) }
            .shareReplay(1)
        
        self.sendEmailCodeComplete = sendEmailCodeRequest
            .filterSuccess()
            .map {_ in ()}
        
        self.loadingViewModel = LoadingViewModel([
            sendEmailCodeRequest.isLoading()
        ])
        
        self.errors = Observable.merge([
            sendEmailCodeRequest.filterError()
        ])
    }
}
