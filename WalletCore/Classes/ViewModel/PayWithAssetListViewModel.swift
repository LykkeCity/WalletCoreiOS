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
        let assetPairs = authManager.assetPairs.requestAssetPairs()
        
        loadingViewModel = LoadingViewModel([
            nonEmptyWallets.map{ _ in false }.startWith(true),
            assetPairs.isLoading()
        ])
        
        payWithWalletList =
            Observable.combineLatest(nonEmptyWallets, buyAsset, assetPairs.filterSuccess())
            .map{(wallets, buyAsset, assetPairs) in
                return wallets.filter{(wallet: LWSpotWallet) in
                    guard let walletAssetId = wallet.asset.identity, let assetId = buyAsset.identity else {
                        return false
                    }
                    
                    let possiblePairs = ["\(assetId)\(walletAssetId)", "\(walletAssetId)\(assetId)"]
                    return assetPairs.contains{ possiblePairs.contains($0.identity) }
                }
            }
    }
}
