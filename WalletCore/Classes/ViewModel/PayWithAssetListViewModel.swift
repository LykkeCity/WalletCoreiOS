//
//  PayWithAssetListViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/9/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class PayWithAssetListViewModel {
    public let payWithWalletList: Observable<[LWSpotWallet]>
    public let loadingViewModel: LoadingViewModel

    public init(buyAsset: Observable<LWAssetModel>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {

        let nonEmptyWallets = authManager.lykkeWallets.requestNonEmptyWallets()
        let assetPairs = authManager.assetPairs.request()
        let assetPairRates = authManager.assetPairRates.request(withParams: true)

        loadingViewModel = LoadingViewModel([
            nonEmptyWallets.isLoading(),
            assetPairs.isLoading()
        ])

        payWithWalletList =
            Observable.combineLatest(nonEmptyWallets.filterSuccess(), buyAsset, assetPairs.filterSuccess(), assetPairRates.filterSuccess())
            .map {(wallets, buyAsset, assetPairs, assetPairRates) in
                let pairRatesSet = Set(assetPairRates.map { $0.identity })
                let pairsWithRates = assetPairs.filter { pairRatesSet.contains($0.identity) }
                return wallets.filter { (wallet: LWSpotWallet) in
                    return pairsWithRates.contains { pair in
                        return  (pair.baseAsset == buyAsset && pair.quotingAsset == wallet.asset) ||
                                (pair.baseAsset == wallet.asset && pair.quotingAsset == buyAsset)
                    }
                }
            }
    }
}
