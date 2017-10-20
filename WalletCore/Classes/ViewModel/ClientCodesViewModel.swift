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
    
    public let encodeMainKeyObservable : Observable<LWPacketEncodedMainKey>
    public let errors: Observable<[AnyHashable: Any]>
    public let loadingViewModel: LoadingViewModel
    
    public init(
        trigger: Observable<Void>,
        dependency: (authManager: LWRxAuthManager, keychainManager: LWKeychainManager)
    ) {
    
        
        let getClientCodeObservable = trigger
            .flatMapLatest{_ in dependency.authManager.getClientCodes.requestGetClientCodes()}
            .shareReplay(1)

        let postClientCodesObservable = getClientCodeObservable.filterSuccess()
            .flatMapLatest{result in
                dependency.authManager.postClientCodes.requestPostClientCodes(codeSms: result.codeSms)
            }
            .shareReplay(1)
        
        let encodeMainKeyObservable = postClientCodesObservable.filterSuccess()
            .flatMapLatest {result in
                dependency.authManager.encodeMainKey.requestEncodeMainKey(accessToken:result.accessToken)
            }
            .shareReplay(1)
        
        //call pin security and then retry getting main key
        let validatePin = encodeMainKeyObservable
            .filterForbidden()
            .flatMap{
                dependency.authManager.pinget.validatePin(withData: dependency.keychainManager.pin() ?? "")
            }
            .shareReplay(1)
        
        let retriedEncodeMainKey = validatePin.filterSuccess()
            .withLatestFrom(postClientCodesObservable.filterSuccess())
            .flatMap{result in
                dependency.authManager.encodeMainKey.requestEncodeMainKey(accessToken:result.accessToken)
            }
            .shareReplay(1)
        
        self.encodeMainKeyObservable = Observable.merge(
            encodeMainKeyObservable.filterSuccess(),
            retriedEncodeMainKey.filterSuccess()
        )
        
        self.errors = Observable.merge(
            getClientCodeObservable.filterError(),
            postClientCodesObservable.filterError(),
            encodeMainKeyObservable.filterError(),
            getClientCodeObservable.filterForbidden().map{["Message": "Getting client got is forbidden."]},
            postClientCodesObservable.filterForbidden().map{["Message": "Post client codes is forbidden."]},
            retriedEncodeMainKey.filterForbidden().map{["Message": "Getting main key is forbidden"]}
        )
        
        loadingViewModel = LoadingViewModel([
            getClientCodeObservable.isLoading(),
            postClientCodesObservable.isLoading(),
            encodeMainKeyObservable.isLoading(),
            validatePin.isLoading(),
            retriedEncodeMainKey.isLoading()
        ])
    }
}
