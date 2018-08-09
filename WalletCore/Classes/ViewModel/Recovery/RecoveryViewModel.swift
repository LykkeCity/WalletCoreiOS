//
//  RecoveryViewModel.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 7.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class RecoveryViewModel {
    
    private struct RecoveryData {
        /// Data properties
        let email,
        ownershipMsg,
        smsCode,
        newPin,
        newPassword: String
        
        /// Validate data
        func isDataValid() -> Bool {
            return email.isNotEmpty && ownershipMsg.isNotEmpty && smsCode.isNotEmpty && newPassword.isNotEmpty
        }
    }
    
    /// Singleton
    public static let instance = RecoveryViewModel()

    public let email = Variable<String>("")
    public let signedOwnershipMessage = Variable<String>("")
    public let smsCode = Variable<String>("")
    public let newPin = Variable<String>("")
    public let newPassword = Variable<String>("")
    
    public let resendSmsTrigger = PublishSubject<Void>()
    
    public let changePinAndPasswordTrigger = PublishSubject<Void>()

    public let resendSmsData: Observable<(phone: String, signedOwnershipMessage: String)>
    
    public let success: Observable<Void>
    
    public let errors: Observable<[AnyHashable: Any]>
    
    /// Loading
    public let loadingViewModel: LoadingViewModel
    
    public lazy var isValidSmsCode: Observable<Bool> = {
        return self.smsCode.asObservable()
            .map { $0.count >= 4 }
            .debug()
    }()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let recoverySmsRequest = Observable.combineLatest(
            email.asObservable(),
            signedOwnershipMessage.asObservable())
            .debug("req")
            .filter { !$0.0.isEmpty && !$0.1.isEmpty }
            .debug("req filter")
            .flatMapLatest { data in
                authManager.recoverySmsConfirmation.request(withParams: data)
        }
            .debug("after req")
            .shareReplay(1)

         resendSmsData = resendSmsTrigger
            .debug("TRIGGER")
            .flatMapLatest { _ in return recoverySmsRequest }
            .filterSuccess()
            .map( { data in
                return (phone: data.recModel.phoneNumber, signedOwnershipMessage: data.recModel.securityMessage2)
            })
            .shareReplay(1)
        
        
        let recoveryData: Observable<LWRecoveryPasswordModel> = Observable.combineLatest(
            email.asObservable(),
            signedOwnershipMessage.asObservable(),
            smsCode.asObservable(),
            newPin.asObservable(),
            newPassword.asObservable()
        ) { RecoveryData(email: $0, ownershipMsg: $1, smsCode: $2, newPin: $3, newPassword: $4) }
            .filter { $0.isDataValid() }
            .debug("Recovery data")
            .map { data in
                let model = LWRecoveryPasswordModel()
                model.email = data.email
                model.signature2 = data.ownershipMsg
                model.smsCode = data.smsCode
                model.pin = data.newPin
                model.password = data.newPassword
                
                return model
            }
            .shareReplay(1)
            
        let changePinAndPasswordData = changePinAndPasswordTrigger.withLatestFrom(recoveryData)
            .flatMapLatest { authManager.changePinAndPassword.request(withParams: $0) }
            .debug("DATA IS HERE !")
            .shareReplay(1)
        
        success = changePinAndPasswordData.asObservable()
            .debug("Pre success")
            .filterSuccess()
            .map { _ in return () }
        
        errors = Observable.merge([
            changePinAndPasswordData.filterError(),
            recoverySmsRequest.filterError()
            ])
        
        self.loadingViewModel = LoadingViewModel([
            changePinAndPasswordData.isLoading(),
            changePinAndPasswordData.isLoading()
            ])
    }
    
    public func reset() {
        email.value = ""
        signedOwnershipMessage.value = ""
        smsCode.value = ""
        newPin.value = ""
        newPassword.value = ""
    }
}
