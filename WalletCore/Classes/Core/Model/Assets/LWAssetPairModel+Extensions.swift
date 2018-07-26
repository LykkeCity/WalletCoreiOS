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
extension Array where Element == LWAssetPairModel {
    func find(byPair pair: String?) -> LWAssetPairModel? {
        return first {$0.identity ?? "" == pair}
    }

    func find(assets: [LWAssetModel?]) -> LWAssetPairModel? {
        guard assets.count >= 0 else { return nil}
        guard let first = assets[0] else { return nil}
        guard let second = assets[1] else { return nil }

        let pair = first.getPairId(withAsset: second)
        let reversedPair = second.getPairId(withAsset: first)
        guard let pairModel = find(byPair: pair) else {
            return find(byPair: reversedPair)
        }

        return pairModel
    }

    func find(assets: [String?]) -> LWAssetPairModel? {
        guard assets.count >= 0 else { return nil}
        guard let first = assets[0] else { return nil}
        guard let second = assets[1] else { return nil }

        let pair = "\(first)\(second)"
        let reversedPair = "\(second)\(first)"
        guard let pairModel = find(byPair: pair) else {
            return find(byPair: reversedPair)
        }

        return pairModel
    }

}
