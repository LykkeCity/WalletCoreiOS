//
//  MarketCapCellViewModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 21.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public class MarketCapCellViewModel {
    public let symbol: Driver<String>
    public let price: Driver<String>
    public let marketCap: Driver<String>
    public let percentChange: Driver<String>
    
    public init(withMarketCapResut marketCapResult: LWModelMarketCapResult) {
        self.symbol = marketCapResult.symbol
        self.price = marketCapResult.price
        self.marketCap = marketCapResult.marketCap
        self.percentChange = marketCapResult.percentChange
    }
}
