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
        newPassword,
        newHint: String
        
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
    public let newHint = Variable<String>("")
    public let phoneNumber = Variable<String>("")
    
    /// IN: call when SMS resend is invoked
    public let resendSmsTrigger = PublishSubject<Void>()
    
    /// OUT: The phone number to which the SMS is sent
    public let resendSmsData: Driver<String>

//    public let voiceCallTrigger = PublishSubject<Void>()
//
//    public let changePinAndPasswordTrigger = PublishSubject<Void>()

//    public let voiceCallData: Observable<Void>
//
//    public let success: Observable<Void>
//
//    public let errors: Observable<[AnyHashable: Any]>
    
    /// Loading
//    public let loadingViewModel: LoadingViewModel
    
    /// Determine the validity of the SMS code to enable/disable the CONFIRM button
    public let isValidSmsCode: Observable<Bool>
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let recoveryData: Observable<LWRecoveryPasswordModel> = Observable.combineLatest(
            email.asObservable(),
            signedOwnershipMessage.asObservable(),
            smsCode.asObservable(),
            newPin.asObservable(),
            newPassword.asObservable(),
            newHint.asObservable()
        ) { RecoveryData(email: $0, ownershipMsg: $1, smsCode: $2, newPin: $3, newPassword: $4, newHint: $5) }
            .filter { $0.isDataValid() }
            .map { data in
                let model = LWRecoveryPasswordModel()
                model.email = data.email
                model.signature2 = data.ownershipMsg
                model.smsCode = data.smsCode
                model.pin = data.newPin
                model.password = data.newPassword
                model.hint = data.newHint
                
                return model
            }
            .shareReplay(1)
        
        let recoverySmsRequest = Observable.combineLatest(email.asObservable(), signedOwnershipMessage.asObservable()) { (email: $0, signature: $1) }
            .flatMapLatest { authManager.recoverySmsConfirmation.request(withParams: $0) }
            .shareReplay(1)
        
        self.resendSmsData = resendSmsTrigger
            .withLatestFrom(recoverySmsRequest.filterSuccess())
            .map { $0.recModel.phoneNumber }
            .asDriver(onErrorJustReturn: "")
        
        self.isValidSmsCode = self.smsCode.asObservable()
            .map { $0.count >= 4 }
        
//
//        let recoverySmsRequest = Observable.combineLatest(email.asObservable(), signedOwnershipMessage.asObservable()) { (email: $0, signature: $1) }
//            .filter { $0.email.isNotEmpty && $0.signature.isNotEmpty }
//            .flatMapLatest { params in
//                authManager.recoverySmsConfirmation.request(withParams: params)
//            }
//            .shareReplay(1)
//
//         resendSmsData = resendSmsTrigger
//            .flatMapLatest { recoverySmsRequest }
//            .filterSuccess()
//            .map( { data in
//                return (phone: data.recModel.phoneNumber, signedOwnershipMessage: data.recModel.securityMessage2)
//            })
//            .shareReplay(1)
//
//        let changePinAndPasswordData = changePinAndPasswordTrigger
//            .withLatestFrom(recoveryData)
//            .flatMapLatest { authManager.changePinAndPassword.request(withParams: $0) }
//            .shareReplay(1)
//
//        let voiceCallRequest = Observable.combineLatest(phoneNumber.asObservable(), email.asObservable()) { (phoneNumber: $0, email: $1) }
//            .filter { $0.phoneNumber.isNotEmpty && $0.email.isNotEmpty }
//            .flatMapLatest { params in
//                authManager.requestVoiceCall.request(withParams: params)
//            }
//            .shareReplay(1)
//
//        voiceCallData = voiceCallTrigger
//            .withLatestFrom(voiceCallRequest)
//            .map { data in
//                return data.isSuccess
//            }
//            .shareReplay(1)
//
//
//        success = changePinAndPasswordData.filterSuccess()
//            .map { _ in return () }
//
//        errors = Observable.merge([
//            changePinAndPasswordData.filterError(),
//            recoverySmsRequest.filterError(),
//            voiceCallRequest.filterError()
//            ])
//
//        self.loadingViewModel = LoadingViewModel([
//            changePinAndPasswordData.isLoading().debug("changePinAndPasswordData"),
//            recoverySmsRequest.isLoading().debug("recoverySmsRequest"),
//            voiceCallRequest.isLoading()
//            ])
    }
    
    public func reset() {
        email.value = ""
        signedOwnershipMessage.value = ""
        smsCode.value = ""
        newPin.value = ""
        newPassword.value = ""
    }
}
