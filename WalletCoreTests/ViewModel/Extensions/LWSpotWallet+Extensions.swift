//
//  LWSpotWallet+Extensions.swift
//  WalletCoreTests
//
//  Created by Georgi Stanev on 4.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
@testable import WalletCore

extension LWSpotWallet {
    convenience init(assetId: String) {
        self.init()
        asset = LWAssetModel(assetId: assetId)
    }
}
