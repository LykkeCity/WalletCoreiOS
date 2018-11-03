//
//  LWEthereumTransactionsManager+Rx.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/12/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base : LWEthereumTransactionsManager {
    
    private var cache: LWCache {
        get { return LWCache.instance() }
    }
    
    func requestTrade(forBaseAsset: LWAssetModel, pair: LWAssetPairModel, addressTo: String, volume: Decimal) -> Observable<ApiResult<[AnyHashable: Any]>> {
        let manager = self.base
        return Observable.create{[weak manager] observer in
            manager?.requestTrade(forBaseAsset: forBaseAsset, pair: pair, addressTo: addressTo, volume: NSDecimalNumber(decimal: volume)) {data in
                observer.onNext(.success(withData: data ?? [:]))
            }
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func createEthereumSign(forAsset asset: LWAssetModel) -> Observable<ApiResult<LWAssetModel>> {
        
        if let blockchainDepositAddress = cache.getAsset(byId: asset.identity)?.blockchainDepositAddress {
            asset.blockchainDepositAddress = blockchainDepositAddress
            return Observable
                .just(ApiResult.success(withData: asset))
                .startWith(ApiResult.loading)
        }
        
        // createEthereumSign will create wallet address and will refresh all assets in the cache
        return Observable.create { observer in
            LWEthereumTransactionsManager.shared().createEthereumSign(forAsset: asset, completion: { (success) in
                observer.onNext(success ? ApiResult.success(withData: asset) : ApiResult.error(withData: [:]))
                observer.onCompleted()
            })
            return Disposables.create()
        }
        .postWhenSuccess(notification: .blockchainAddressReceived)
        .startWith(.loading)
    }
}
