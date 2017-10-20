//
//  FakeData.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import Charts
import WalletCore

class FakeData{
    
    static let historyGraphData = [
        LWHistoryGraphModel(
            baseValue: Asset.Currency(identity: "USD", name: "Dollars", shortName: "USD", value: 285512.0, accuracy: 2, sign: "$"),
            value: Asset.Currency(identity: "BTC", name: "Dollars", shortName: "BTC", value: 123.0, accuracy: 2, sign: "$")
        ),
        LWHistoryGraphModel(
            baseValue: Asset.Currency(identity: "USD", name: "Dollars", shortName: "USD", value: 285452.0, accuracy: 2, sign: "$"),
            value: Asset.Currency(identity: "BTC", name: "Dollars", shortName: "BTC", value: 124.0, accuracy: 2, sign: "")
        ),
        LWHistoryGraphModel(
            baseValue: Asset.Currency(identity: "USD", name: "Dollars", shortName: "USD", value: 285500.0, accuracy: 2, sign: "$"),
            value: Asset.Currency(identity: "BTC", name: "Dollars", shortName: "BTC", value: 125.0, accuracy: 2, sign: "")
        ),
        LWHistoryGraphModel(
            baseValue: Asset.Currency(identity: "USD", name: "Dollars", shortName: "USD", value: 285512.0, accuracy: 2, sign: "$"),
            value: Asset.Currency(identity: "BTC", name: "Dollars", shortName: "BTC", value: 126.0, accuracy: 2, sign: "")
        ),
        LWHistoryGraphModel(
            baseValue: Asset.Currency(identity: "USD", name: "Dollars", shortName: "USD", value: 285600.0, accuracy: 2, sign: "$"),
            value: Asset.Currency(identity: "BTC", name: "Dollars", shortName: "BTC", value: 127.0, accuracy: 2, sign: "")
        ),
        LWHistoryGraphModel(
            baseValue: Asset.Currency(identity: "USD", name: "Dollars", shortName: "USD", value: 285612.0, accuracy: 2, sign: "$"),
            value: Asset.Currency(identity: "BTC", name: "Dollars", shortName: "BTC", value: 128.0, accuracy: 2, sign: "")
        ),
        LWHistoryGraphModel(
            baseValue: Asset.Currency(identity: "USD", name: "Dollars", shortName: "USD", value: 285620.0, accuracy: 2, sign: "$"),
            value: Asset.Currency(identity: "BTC", name: "Dollars", shortName: "BTC", value: 129.0, accuracy: 2, sign: "b")
        )
    ].enumerated().map{(offset, element) in
        return ChartDataEntry(x:  Double(offset), y: element.baseValue.value.doubleValue, data: element as AnyObject)
    }
    
    static let cryptoCyrrency = Variable([
        Variable(LWACurrencyMarketValueModel(
            name: "BITCOIN",
            capitalization: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 19353702532.00, accuracy: 2, sign: "$"),
            variance: LWACurrencyMarketValueModel.Variance(
                currency: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 1222.56, accuracy: 2,  sign: "$"),
                percent: 0.34
            )
        )),
        Variable(LWACurrencyMarketValueModel(
            name: "BITCOIN",
            capitalization: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 19353702532.00, accuracy: 2, sign: "$"),
            variance: LWACurrencyMarketValueModel.Variance(
                currency: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 1222.56, accuracy: 2,  sign: "$"),
                percent: 0.34
            )
        )),
        Variable(LWACurrencyMarketValueModel(
            name: "BITCOIN",
            capitalization: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 19353702532.00, accuracy: 2, sign: "$"),
            variance: LWACurrencyMarketValueModel.Variance(
                currency: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 1222.56, accuracy: 2,  sign: "$"),
                percent: 0.34
            )
        )),
        Variable(LWACurrencyMarketValueModel(
            name: "BITCOIN",
            capitalization: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 19353702532.00, accuracy: 2, sign: "$"),
            variance: LWACurrencyMarketValueModel.Variance(
                currency: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 1222.56, accuracy: 2,  sign: "$"),
                percent: 0.34
            )
        )),
        Variable(LWACurrencyMarketValueModel(
            name: "BITCOIN",
            capitalization: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 19353702532.00, accuracy: 2, sign: "$"),
            variance: LWACurrencyMarketValueModel.Variance(
                currency: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 1222.56, accuracy: 2,  sign: "$"),
                percent: 0.34
            )
        )),
        Variable(LWACurrencyMarketValueModel(
            name: "BITCOIN",
            capitalization: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 19353702532.00, accuracy: 2, sign: "$"),
            variance: LWACurrencyMarketValueModel.Variance(
                currency: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 1222.56, accuracy: 2,  sign: "$"),
                percent: 0.34
            )
        )),
        Variable(LWACurrencyMarketValueModel(
            name: "BITCOIN",
            capitalization: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 19353702532.00, accuracy: 2, sign: "$"),
            variance: LWACurrencyMarketValueModel.Variance(
                currency: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 1222.56, accuracy: 2,  sign: "$"),
                percent: 0.34
            )
        )),
        Variable(LWACurrencyMarketValueModel(
            name: "BITCOIN",
            capitalization: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 19353702532.00, accuracy: 2, sign: "$"),
            variance: LWACurrencyMarketValueModel.Variance(
                currency: Asset.Currency(identity: "USD", name: "US DOLLARS", shortName: "USD", value: 1222.56, accuracy: 2,  sign: "$"),
                percent: 0.34
            )
        )),
       
   ])
}
