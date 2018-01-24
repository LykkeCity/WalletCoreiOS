//
//  BaseAssetsViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class BaseAssetsViewModel {
    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketBaseAssets>>
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        let allAssets = authManager.allAssets.request().filterSuccess()
        result = allAssets
            .throttle(1, scheduler: MainScheduler.instance)
            .map { _ in return () }
            .mapAssets(authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loading = result.asObservable().isLoading()
    }
}

fileprivate extension ObservableType where Self.E == Void {
    
    func mapAssets(
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketBaseAssets>> {
        
        return flatMapLatest { authManager.baseAssets.request(withParams: ()) }
            .shareReplay(1)
    }
}
