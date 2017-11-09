//
//  BaseAssetSetViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/29/17.
//
//

import Foundation
import RxSwift
import RxCocoa


open class BaseAssetSetViewModel {
    public let identity = Variable<String>("")
    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketBaseAssetSet>>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapIdentity(identity: self.identity, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loading = result.asObservable().isLoading()
    }
}

fileprivate extension ObservableType where Self.E == Void {
    
    func mapIdentity(
        identity: Variable<String>,
        authManager: LWRxAuthManager
    ) -> Observable<ApiResult<LWPacketBaseAssetSet>> {
        
        return flatMapLatest{authData in
            authManager.baseAssetSet.request(withParams: identity.value)
        }
        .shareReplay(1)
    }
}
