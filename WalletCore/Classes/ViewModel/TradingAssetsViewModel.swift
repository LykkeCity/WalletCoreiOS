//
//  TradingAssetsViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/9/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class TradingAssetsViewModel {
    public let availableToBuy: Observable<[LWAssetModel]>
    public let availableToSell: Observable<[LWAssetModel]>
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let nonEmptyWallets =  authManager.lykkeWallets.requestNonEmptyWallets()
        let allAssets = authManager.allAssets.requestAllAssets()
        let assetPairs = authManager.assetPairs.requestAssetPairs()
        
        availableToSell =
            nonEmptyWallets.map{$0.map{$0.asset!}}
        
        availableToBuy =
            Observable.zip(nonEmptyWallets, allAssets.filterSuccess(), assetPairs.filterSuccess())
            .map{wallets, assets, pairs in
                assets.filter{asset in
                    guard let assetId = asset.identity else {return false}
                    return wallets.contains(withAssetId: assetId, assetPairs: pairs)
                }
            }
    }
}

fileprivate extension Array where Element == LWSpotWallet {
    func contains(withAssetId assetId: String, assetPairs: [LWAssetPairModel]) -> Bool {
        return contains{wallet in
            guard let walletId = wallet.asset.identity else {return false}
            let pairId = "\(assetId)\(walletId)"
            
            return assetPairs.contains{assetPair in assetPair.identity == pairId}
        }
    }
}
