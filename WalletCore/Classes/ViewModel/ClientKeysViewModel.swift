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

    public let loadingViewModel: LoadingViewModel
    public let result: Driver<ApiResult<LWPacketClientKeys>>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        let result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapClientKeys(pubKey: pubKey, encodedPrivateKey: encodedPrivateKey,  authManager: authManager)
        
        
        self.result = result.asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loadingViewModel = LoadingViewModel([
            result.isLoading()
        ])
    }
    

}

fileprivate extension ObservableType where Self.E == Void {
    func mapClientKeys(
        pubKey: Variable<String>,
        encodedPrivateKey: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketClientKeys>> {
        
        return flatMapLatest{authData in
            authManager.pubKeys.request(withParams: (
                pubKey: pubKey.value,
                encodedPrivateKey: encodedPrivateKey.value
            ))
        }
        .shareReplay(1)
    }
}

