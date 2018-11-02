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
    
    func createEthereumSign(forAsset asset: LWAssetModel) -> Observable<ApiResult<LWAssetModel>> {
        return Observable.create { observer in
            LWEthereumTransactionsManager.shared().createEthereumSign(forAsset: asset, completion: { (success) in
                observer.onNext(success ? ApiResult.success(withData: asset) : ApiResult.error(withData: [:]))
                observer.onCompleted()
            })
            return Disposables.create()
        }
        .do(onNext: { asset in
            //check if the asset exist and set the blockchainDepositAddress
            guard let assetsFromCache = (LWCache.instance()?.allAssets as? [LWAssetModel]),
                let receivedAsset = asset.getSuccess() else { return }
            assetsFromCache.first(where: { $0.identity == receivedAsset.identity })?.blockchainDepositAddress = receivedAsset.blockchainDepositAddress // set the address
        })
        .do(onNext: { _ in
            NotificationCenter.default.post(name: .blockchainAddressReceived, object: nil)
        })
        .startWith(.loading)
    }
}
