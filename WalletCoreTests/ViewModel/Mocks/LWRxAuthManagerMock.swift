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

    let assetPairRates: LWRxAuthManagerAssetPairRatesProtocol
    let baseAsset: LWRxAuthManagerBaseAssetProtocol
    let allAssets: LWRxAuthManagerAllAssetsProtocol
    let assetPairs: LWRxAuthManagerAssetPairsProtocol

    init(
        baseAsset: LWRxAuthManagerBaseAssetMock = LWRxAuthManagerBaseAssetMock(asset: LWAssetModel(assetId: "USD")),
        allAssets: LWRxAuthManagerAllAssetsMock = LWRxAuthManagerAllAssetsMock(),
        assetPairRates: LWRxAuthManagerAssetPairRatesMock = LWRxAuthManagerAssetPairRatesMock(data: []),
        assetPairs: LWRxAuthManagerAssetPairsMock = LWRxAuthManagerAssetPairsMock(data: [])

    ) {
        self.baseAsset = baseAsset
        self.allAssets = allAssets
        self.assetPairRates = assetPairRates
        self.assetPairs = assetPairs
    }
}
