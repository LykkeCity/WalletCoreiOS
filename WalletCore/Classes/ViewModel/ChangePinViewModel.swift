//
//  ChangePinViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ChangePinViewModel {
    
    // IN:
    /// Recovery data used both as observer and observable
    public let recoveryModel = PublishSubject<LWRecoveryPasswordModel>()
    
    // OUT:
    /// Confirm, that the password and the pin are changed
    public let isChangeConfirmed: Observable<Void>
    
    /// Loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Errors occured
    public let errors: Observable<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let changePinRequest = recoveryModel.asObservable()
            .flatMapLatest { authManager.changePinAndPassword.request(withParams: $0) }
            .shareReplay(1)
        
        self.isChangeConfirmed = changePinRequest.filterSuccess()
            .map { _ in return () }
        
        self.loadingViewModel = LoadingViewModel([
            changePinRequest.isLoading()
        ])
        
        self.errors = Observable.merge([
            changePinRequest.filterError()
        ])

    }
}
