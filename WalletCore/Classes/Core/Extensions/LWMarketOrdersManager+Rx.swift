//
//  LWMarketOrdersManager+Rx.swift
//  WalletCore
//
//  Created by Nacho Nachev  on 21.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

extension LWMarketOrdersManager {

    public class func createOrder(assetPair: LWAssetPairModel, assetId: String, isSell: Bool, volume: String) -> Observable<ApiResult<LWAssetDealModel?>> {
        return Observable.create({ (observer) -> Disposable in
            LWMarketOrdersManager.createOrder(assetPair: assetPair, assetId: assetId, isSell: isSell, volume: volume, completion: { (model) in
                observer.onNext(.success(withData: model))
                observer.onCompleted()
            })

            observer.onNext(.loading)
            return Disposables.create {}
        })
    }

}
