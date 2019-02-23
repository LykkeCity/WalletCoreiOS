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
        let assetPairRates = authManager.assetPairRates.request(withParams: true)

        loadingViewModel = LoadingViewModel([
            nonEmptyWallets.isLoading(),
            allAssets.isLoading(),
            assetPairs.isLoading()
        ])
        
        availableToSell = nonEmptyWallets.filterSuccess()
        
        availableToBuy =
            Observable.combineLatest(nonEmptyWallets.filterSuccess(), allAssets.filterSuccess(), assetPairs.filterSuccess(), assetPairRates.filterSuccess())
                .map{wallets, assets, pairs, pairRates in
                    let pairRatesSet = Set(pairRates.map { $0.identity })
                    let pairsWithRates = pairs.filter { pairRatesSet.contains($0.identity) }
                    return assets.filter { asset in wallets.contains(withAsset: asset, assetPairs: pairsWithRates) }
        }
    }
}

extension Array where Element == LWSpotWallet {
    func contains(withAsset asset: LWAssetModel, assetPairs: [LWAssetPairModel]) -> Bool {
        return contains { wallet in
            return assetPairs.contains { pair in
                return  (pair.baseAsset == wallet.asset && pair.quotingAsset == asset) ||
                        (pair.quotingAsset == wallet.asset && pair.baseAsset == asset)
            }
        }
    }
}
