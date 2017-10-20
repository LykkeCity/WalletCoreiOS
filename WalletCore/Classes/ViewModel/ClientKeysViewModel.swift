//
//  ClientKeysViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 9/4/17.
//
//


import Foundation
import RxSwift
import RxCocoa

open class ClientKeysViewModel {

    public let pubKey = Variable<String>("")
    public let encodedPrivateKey = Variable<String>("")

    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketClientKeys>>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapClientKeys(pubKey: pubKey, encodedPrivateKey: encodedPrivateKey,  authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loading = result.asObservable().isLoading()
    }
    

}

fileprivate extension ObservableType where Self.E == Void {
    func mapClientKeys(
        pubKey: Variable<String>,
        encodedPrivateKey: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketClientKeys>> {
        
        return flatMapLatest{authData in
            authManager.pubKeys.setClientKeys(withPubKey: pubKey.value, encodedPrivateKey: encodedPrivateKey.value)
            }
            .shareReplay(1)
    }
}

