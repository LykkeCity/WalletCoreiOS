
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
            authManager.assetPairs.request().filterSuccess()
        )
        .map{(assets, sellAsset, assetPairs) in
            return assets.filter{(asset: LWAssetModel) in
                
                guard let walletAssetId = sellAsset.displayId, let assetId = asset.displayId else {
                    return false
                }
                
                let possiblePairs = ["\(assetId)\(walletAssetId)", "\(walletAssetId)\(assetId)"]
                return assetPairs.contains{ possiblePairs.contains($0.identity) }
            }
        }
    }
}
