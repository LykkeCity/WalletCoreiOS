//
//  LWRxAuthManagerMock.swift
//  WalletCoreTests
//
//  Created by Georgi Stanev on 3.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift
@testable import WalletCore

class LWRxAuthManagerMock: LWRxAuthManagerProtocol {
    var baseAssets: LWRxAuthManagerBaseAssetsProtocol
    let assetPairRates: LWRxAuthManagerAssetPairRatesProtocol
    let baseAsset: LWRxAuthManagerBaseAssetProtocol
    let allAssets: LWRxAuthManagerAllAssetsProtocol
    let assetPairs: LWRxAuthManagerAssetPairsProtocol
    
    init(
        baseAssets: LWRxAuthManagerBaseAssetsMock = LWRxAuthManagerBaseAssetsMock(asset: []),
        baseAsset: LWRxAuthManagerBaseAssetMock = LWRxAuthManagerBaseAssetMock(asset: LWAssetModel(assetId: "USD")),
        allAssets: LWRxAuthManagerAllAssetsMock = LWRxAuthManagerAllAssetsMock(),
        assetPairRates:LWRxAuthManagerAssetPairRatesMock = LWRxAuthManagerAssetPairRatesMock(data: []),
        assetPairs:LWRxAuthManagerAssetPairsMock = LWRxAuthManagerAssetPairsMock(data: [])
    ) {
        self.baseAssets = baseAssets
        self.baseAsset = baseAsset
        self.allAssets = allAssets
        self.assetPairRates = assetPairRates
        self.assetPairs = assetPairs
    }
    
//    LWAssetPairModel.assetPair(withDict: ["Id":"EURUSD","BaseAssetId":"EUR","QuotingAssetId":"USD"])!,
//    LWAssetPairModel.assetPair(withDict: ["Id":"BTCUSD","BaseAssetId":"BTC","QuotingAssetId":"USD"])!,
//    LWAssetPairModel.assetPair(withDict: ["Id":"BTCAUD","BaseAssetId":"BTC","QuotingAssetId":"AUD"])!,
//    LWAssetPairModel.assetPair(withDict: ["Id":"USDAUD","BaseAssetId":"USD","QuotingAssetId":"AUD"])!
}
