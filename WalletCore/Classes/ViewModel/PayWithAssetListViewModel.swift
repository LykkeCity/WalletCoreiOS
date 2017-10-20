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
    public let payWithAssetList: Observable<[LWAssetModel]>
    
    public init(buyAsset: Observable<LWAssetModel>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        payWithAssetList =
            Observable.combineLatest(
                authManager.lykkeWallets.requestNonEmptyWallets(),
                buyAsset,
                authManager.assetPairs.requestAssetPairs().filterSuccess()
            )
            .map{(wallets, buyAsset, assetPairs) in
                return wallets.filter{(wallet: LWSpotWallet) in
                    guard let walletAssetId = wallet.asset.identity, let assetId = buyAsset.identity else {
                        return false
                    }
                    
                    let assetPairId = "\(assetId)\(walletAssetId)"
                    return assetPairs.contains{$0.identity == assetPairId}
                }
            }
            .map{$0.map{$0.asset!}}
    }
}
