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
        let assetPairs = authManager.assetPairRates.request(withParams: true)
        
        loadingViewModel = LoadingViewModel([
            nonEmptyWallets.isLoading(),
            allAssets.isLoading(),
            assetPairs.isLoading()
        ])
        
        availableToSell = nonEmptyWallets.filterSuccess()
        
        availableToBuy =
            Observable.zip(nonEmptyWallets.filterSuccess(), allAssets.filterSuccess(), assetPairs.filterSuccess())
                .map{wallets, assets, pairs in
                    let pairsSet = Set(pairs.map { $0.identity })
                    return assets.filter{asset in
                        guard let assetId = asset.displayId else { return false }
                        return wallets.contains(withAssetId: assetId, assetPairs: pairsSet)
                    }
        }
    }
}

extension Array where Element == LWSpotWallet {
    func contains(withAssetId assetId: String, assetPairs: Set<String>) -> Bool {
        return contains{wallet in
            guard let walletId = wallet.asset.displayId else {return false}
            let possiblePairs: Set = ["\(assetId)\(walletId)", "\(walletId)\(assetId)"]
            return !assetPairs.isDisjoint(with: possiblePairs)
        }
    }
}
