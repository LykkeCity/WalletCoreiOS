//
//  LWHistoryGraphModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/18/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

public struct LWHistoryGraphModel {
    public let baseValue: Asset.Currency
    public let value: Asset.Currency
    
    public init(baseValue: Asset.Currency, value: Asset.Currency) {
        self.baseValue = baseValue
        self.value = value
    }
}
