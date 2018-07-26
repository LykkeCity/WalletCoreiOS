//
//  Asset.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 6/8/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

public class Asset {
    public var cryptoCurrency: Currency
    public var realCurrency: Currency
    public var percent: Double
    public var wallet: LWSpotWallet?

    public init(wallet: LWSpotWallet, baseAsset: LWAssetModel, mainInfo: LWPacketGetMainScreenInfo) {

        self.wallet = wallet

        self.cryptoCurrency = Currency(
            identity: wallet.asset.identity ?? "",
            name: wallet.asset.displayFullName,
            shortName: wallet.asset.displayName,
            value: (wallet.balance ?? 0.0).decimalValue,
            accuracy: Int(wallet.asset.accuracy)
        )

        self.realCurrency = Currency(
            identity: baseAsset.identity ?? "",
            name: baseAsset.displayFullName,
            shortName: baseAsset.displayName,
            value: wallet.amountInBase.decimalValue,
            accuracy: Int(baseAsset.accuracy),
            sign: baseAsset.symbol ?? ""
        )

        self.percent = mainInfo.totalBalance == 0 ? 0.0 : (self.realCurrency.value / mainInfo.totalBalance).doubleValue * 100
    }

    public init(cryptoCurrency: Currency, realCurrency: Currency, percent: Double) {
        self.cryptoCurrency = cryptoCurrency
        self.realCurrency = realCurrency
        self.percent = percent
    }

    public class Currency {
        public var name: String
        public var shortName: String
        public var value: Decimal
        public var sign: String?
        public var accuracy: Int
        public let identity: String

        public init(identity: String, name: String, shortName: String, value: Decimal, accuracy: Int) {
            self.identity = identity
            self.name = name
            self.shortName = shortName
            self.value = value
            self.accuracy = accuracy
        }

        public convenience init(identity: String, name: String, shortName: String, value: Decimal, accuracy: Int, sign: String) {
            self.init(identity: identity, name: name, shortName: shortName, value: value, accuracy: accuracy)
            self.sign = sign
        }
    }
}
