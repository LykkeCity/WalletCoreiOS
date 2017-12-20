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
        let assetPairs = authManager.assetPairRates.request(withParams: true)
        
        loadingViewModel = LoadingViewModel([
            nonEmptyWallets.isLoading(),
            assetPairs.isLoading()
        ])
        
        payWithWalletList =
            Observable.combineLatest(nonEmptyWallets.filterSuccess(), buyAsset, assetPairs.filterSuccess())
            .map{(wallets, buyAsset, assetPairs) in
                let assetPairsSet = Set(assetPairs.map { $0.identity })
                return wallets.filter{(wallet: LWSpotWallet) in
                    guard let walletAssetId = wallet.asset.displayId, let assetId = buyAsset.displayId else {
                        return false
                    }
                    
                    let possiblePairs: Set = ["\(assetId)\(walletAssetId)", "\(walletAssetId)\(assetId)"]
                    return !assetPairsSet.isDisjoint(with: possiblePairs)
                }
            }
    }
}