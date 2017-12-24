//
//  LWAssetPairModel+Extensions.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/25/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

extension LWAssetPairModel {
    var baseAsset: LWAssetModel? {
        guard let assetId = baseAssetId else {return nil}
        return LWCache.asset(byId: assetId)
    }
    
    var quotingAsset: LWAssetModel? {
        guard let assetId = quotingAssetId else {return nil}
        return LWCache.asset(byId: assetId)
    }
}
