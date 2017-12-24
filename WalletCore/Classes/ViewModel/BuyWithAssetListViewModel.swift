
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
            authManager.assetPairRates.request(withParams: true).filterSuccess()
        )
        .map{(assets, sellAsset, assetPairs) in
            let assetPairsSet = Set(assetPairs.map { $0.identity })
            return assets.filter{ (asset) in
                
                guard let walletAssetId = sellAsset.displayId, let assetId = asset.displayId else {
                    return false
                }
                
                let possiblePairs: Set = ["\(assetId)\(walletAssetId)", "\(walletAssetId)\(assetId)"]
                return !assetPairsSet.isDisjoint(with: possiblePairs)
            }
        }
    }
}
