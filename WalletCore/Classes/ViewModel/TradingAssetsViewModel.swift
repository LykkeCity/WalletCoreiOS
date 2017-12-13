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
    public let availableToSell: Observable<[LWSpotWallet]>
    public let loadingViewModel: LoadingViewModel
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let nonEmptyWallets =  authManager.lykkeWallets.requestNonEmptyWallets()
        let allAssets = authManager.allAssets.request()
        let assetPairs = authManager.assetPairs.request()
        
        loadingViewModel = LoadingViewModel([
            nonEmptyWallets.isLoading(),
            allAssets.isLoading(),
            assetPairs.isLoading()
        ])
        
        availableToSell = nonEmptyWallets.filterSuccess()
        
        availableToBuy =
            Observable.zip(nonEmptyWallets.filterSuccess(), allAssets.filterSuccess(), assetPairs.filterSuccess())
            .map{wallets, assets, pairs in
                assets.filter{asset in
                    guard let assetId = asset.displayId else {return false}
                    return wallets.contains(withAssetId: assetId, assetPairs: pairs)
                }
            }
    }
}

extension Array where Element == LWSpotWallet {
    func contains(withAssetId assetId: String, assetPairs: [LWAssetPairModel]) -> Bool {
        return contains{wallet in
            guard let walletId = wallet.asset.identity else {return false}
            
            let possiblePairs = ["\(assetId)\(walletId)", "\(walletId)\(assetId)"]
            return assetPairs.contains{assetPair in possiblePairs.contains(assetPair.identity)}
        }
    }
}
