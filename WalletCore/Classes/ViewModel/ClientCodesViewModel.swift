//
//  ClientCodesViewModel.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/21/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

open class ClientCodesViewModel {
    
    /// Observable of LWPacketEncodedMainKey that receive events only after encoded main keys is retrieved, decoded && cached
    public let encodeMainKeyObservable : Observable<LWPacketEncodedMainKey>
    
    /// Errors observalbe that accumulates errors from all http calls made in this view model
    public let errors: Observable<[AnyHashable: Any]>
    
    /// Loading view model that merge all http calls
    public let loadingViewModel: LoadingViewModel

    /// - Parameters:
    ///   - smsCodeForRetrieveKey: SMS code sent to the user that he/she should fill in order to get the encoded private key
    ///   - triggerForSMSCode: A trigger for sending sms code
    ///   - dependency: All dependency classes needed for this view model
    public init(
        email: String,
        smsCodeForRetrieveKey: Observable<String>,
        triggerForSMSCode: Observable<Void> = Observable.just(()),
        dependency: (authManager: LWRxAuthManager, keychainManager: LWKeychainManager)
    ) {
        let getClientCodeObservable = triggerForSMSCode
            .flatMapLatest{_ in dependency.authManager.getClientCodes.request()}
            .shareReplay(1)

        let postClientCodesObservable = smsCodeForRetrieveKey
            .flatMapLatest{smsCode in
                dependency.authManager.postClientCodes.request(withParams: smsCode)
            }
            .shareReplay(1)
        
        let accessTokenReceived = postClientCodesObservable.filterSuccess()
            .map { $0.accessToken }
            .filterNil()
            .shareReplay(1)
        
        let emailVerificationObservable = accessTokenReceived
            .flatMapLatest { _ in
                dependency.authManager.emailverification.request(withParams: email)
            }
            .shareReplay(1)
        
        let smsRequestParams = Observable.combineLatest(smsCodeForRetrieveKey, accessTokenReceived) { (email: email, code: $0, accessToken: $1) }
            .shareReplay(1)

        let emailVerificationSmsObservable = emailVerificationObservable.filterSuccess()
            .withLatestFrom(smsRequestParams)
            .flatMapLatest { params in
                dependency.authManager.emailverificationSms.request(withParams: params)
            }
            .shareReplay(1)
        
        let getEncodedPrivateObservable = emailVerificationSmsObservable.filterSuccess()
            .filter { $0.isPassed }
            .withLatestFrom(smsRequestParams)
            .flatMapLatest { dependency.authManager.encodeMainKey.request(withParams: $0.accessToken) }
            .shareReplay(1)
        
        //call pin security and then retry getting main key
        let validatePin = getEncodedPrivateObservable
            .filterForbidden()
            .flatMap{
                dependency.authManager.pinget.request(withParams: dependency.keychainManager.pin() ?? "")
            }
            .shareReplay(1)
        
        let retriedEncodeMainKey = validatePin.filterSuccess()
            .withLatestFrom(accessTokenReceived)
            .flatMap{ result in
                dependency.authManager.encodeMainKey.request(withParams: result)
            }
            .shareReplay(1)
        
//        let verifiedEmail = retriedEncodeMainKey.filterSuccess()
//            .flatMapLatest { dependency.authManager.emailverification.request() }
        
        self.encodeMainKeyObservable = Observable.merge(
            getEncodedPrivateObservable.filterSuccess(),
            retriedEncodeMainKey.filterSuccess()
        )
        
        self.errors = Observable.merge(
            getClientCodeObservable.filterError(),
            postClientCodesObservable.filterError(),
            getEncodedPrivateObservable.filterError(),
            getClientCodeObservable.filterForbidden().map{["Message": "Getting client got is forbidden."]},
            postClientCodesObservable.filterForbidden().map{["Message": "Post client codes is forbidden."]},
            retriedEncodeMainKey.filterForbidden().map{["Message": "Getting main key is forbidden"]}
        )
        
        loadingViewModel = LoadingViewModel([
            getClientCodeObservable.isLoading(),
            postClientCodesObservable.isLoading(),
            getEncodedPrivateObservable.isLoading(),
            emailVerificationObservable.isLoading(),
            emailVerificationSmsObservable.isLoading(),
            validatePin.isLoading(),
            retriedEncodeMainKey.isLoading()
        ])
    }
}
