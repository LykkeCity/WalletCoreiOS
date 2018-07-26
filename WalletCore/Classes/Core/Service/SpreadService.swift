//
//  SpreadService.swift
//  WalletCore
//
//  Created by Ivan Stefanovic on 1/23/18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public protocol SpreadServiceProtocol {

    /// Calculate buyer to seller spread amount in base currency
    ///
    /// - Parameters:
    ///   - buySellPair: buy sell pair
    ///   - secondaryBasePair: secondary asset and base asset pair
    ///   - baseAsset: base asset
    /// - Returns: spread amount in base currecy as a string
    func spreadAmount(buySellPair: LWAssetPairModel?, secondaryBasePair: LWAssetPairModel?, baseAsset: LWAssetModel?) -> String?

    /// Calculate buyer to seller spread percent
    ///
    /// - Parameters:
    ///   - buySellPair: buy sell pair
    /// - Returns: spread amount percent as a string
    func spreadPercent(buySellPair: LWAssetPairModel?) -> String?
}

public class SpreadService: SpreadServiceProtocol {

    public init() {

    }

    public func spreadAmount(buySellPair: LWAssetPairModel?, secondaryBasePair: LWAssetPairModel?, baseAsset: LWAssetModel?) -> String? {
        guard let buySellPairRate = buySellPair?.rate else {return nil}
        guard let baseAsset = baseAsset else {return nil}

        guard let secondaryBasePairRate = secondaryBasePair?.rate else {
            let spread = abs(buySellPairRate.ask.doubleValue - buySellPairRate.bid.doubleValue)
            return Decimal(spread).convertAsCurrency(asset: baseAsset, withCode: false)
        }

        let spread = abs(buySellPairRate.ask.doubleValue - buySellPairRate.bid.doubleValue)
        let secondaryBaseRate = (secondaryBasePairRate.ask.doubleValue + secondaryBasePairRate.bid.doubleValue) / 2
        let spreadInBase =  Decimal(spread * secondaryBaseRate)

        return Decimal(spread).convertAsCurrency(asset: buySellPair?.quotingAsset, withCode: false) + " (~" + spreadInBase.convertAsCurrency(asset: baseAsset, withCode: false) + ")"
    }

    public func spreadPercent(buySellPair: LWAssetPairModel?) -> String? {
        guard let buySellPairRate = buySellPair?.rate else {return nil}

        let spread = abs(buySellPairRate.ask.doubleValue - buySellPairRate.bid.doubleValue)
        let percent = (spread / buySellPairRate.ask.doubleValue) * 100
        return NumberFormatter.percentInstancePerise.string(from: NSDecimalNumber(decimal: Decimal(percent)))
    }
}
