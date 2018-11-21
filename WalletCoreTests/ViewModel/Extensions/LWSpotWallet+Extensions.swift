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


extension Collection where Self.Element == LWSpotWallet {
    
    /// Search for base asset inside the array and returns the first match
    ///
    /// - Returns: Base asset according to wallets
    func findBaseAsset() -> LWAssetModel? {
        return (first{ wallet in wallet.assetPairId != nil })?.findBaseAsset()
    }
}

extension LWSpotWallet {
    
    /// Find base asset according to the assetpair
    /// TODO: don't use the cache in this layer, move it to the repo layer LMW-600
    /// - Returns: Base asset
    func findBaseAsset() -> LWAssetModel? {
        guard let asset = LWCache.asset(byId: identity) else {
            return nil
        }
        
        let assetId = assetPairId.replacingOccurrences(of: asset.displayId, with: "")
        return LWCache.instance()?.getAsset(byDisplayId: assetId)
    }
}
