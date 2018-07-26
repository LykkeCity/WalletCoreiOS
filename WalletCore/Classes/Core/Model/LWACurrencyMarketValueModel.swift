//
//  LWACurrencyMarketValueModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
public class LWACurrencyMarketValueModel {
    public typealias Variance = (currency: Asset.Currency, percent: Double)

    let name: String
    let capitalization: Asset.Currency
    let variance: Variance
    public let imgUrl: URL?

    public init(name: String, capitalization: Asset.Currency, variance: Variance) {
        self.name = name
        self.capitalization = capitalization
        self.variance = variance
        self.imgUrl = nil
    }
    public init(name: String, capitalization: Asset.Currency, variance: Variance, imageUrl: URL?) {
        self.name = name
        self.capitalization = capitalization
        self.variance = variance
        self.imgUrl = imageUrl
    }

}
