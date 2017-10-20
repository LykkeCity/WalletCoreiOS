
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
            authManager.allAssets.requestAllAssets().filterSuccess(),
            sellAsset,
            authManager.assetPairs.requestAssetPairs().filterSuccess()
        )
        .map{(assets, sellAsset, assetPairs) in
            return assets.filter{(asset: LWAssetModel) in
                
                guard let walletAssetId = sellAsset.identity, let assetId = asset.identity else {
                    return false
                }
                
                let assetPairId = "\(walletAssetId)\(assetId)"
                return assetPairs.contains{$0.identity == assetPairId}
            }
        }
    }
}
