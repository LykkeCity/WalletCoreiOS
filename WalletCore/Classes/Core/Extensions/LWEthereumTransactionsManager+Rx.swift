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
    
    func createEthereumSign(forAsset asset: LWAssetModel) -> Observable<(Bool, LWAssetModel)> {
        return Observable.create { observer in
            LWEthereumTransactionsManager.shared().createEthereumSign(forAsset: asset, completion: { (success) in
                observer.onNext((success, asset))
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
}
