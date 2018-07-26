//
//  BuyWithAssetListViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/9/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class BuyWithAssetListViewModel {
    public let buyWithAssetList: Observable<[LWAssetModel]>

    public init(sellAsset: Observable<LWAssetModel>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {

        buyWithAssetList = Observable.combineLatest(
            authManager.allAssets.request().filterSuccess(),
            sellAsset,
            authManager.assetPairs.request().filterSuccess(),
            authManager.assetPairRates.request(withParams: true).filterSuccess()
        )
        .map {(assets, sellAsset, assetPairs, assetPairRates) in
            let pairRatesSet = Set(assetPairRates.map { $0.identity })
            let pairsWithRates = assetPairs.filter { pairRatesSet.contains($0.identity) }
            return assets.filter { (asset) in
                return pairsWithRates.contains { pair in
                    return  (pair.baseAsset == asset && pair.quotingAsset == sellAsset) ||
                            (pair.baseAsset == sellAsset && pair.quotingAsset == asset)
                }
            }
        }
    }
}
