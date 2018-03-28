//
//  LWModelMarketCapResult.swift
//  WalletCore
//
//  Created by Vasil Garov on 6.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public struct LWModelMarketCapResult {

    // The asset symbol like BTC, ETH etc
    public let symbol: String
    // The price of an asset in USD
    public let price: Decimal
    // The market capitalization of an asset in USD
    public let marketCap: Decimal
    // The change in price of an asset for the last 24 hours displayed in percentage
    public let percentChange: Decimal
    
    init(withJSON json: [AnyHashable: Any]) {
        self.symbol = json.symbol
        self.price = json.priceUsd
        self.marketCap = json.marketCapUsd
        self.percentChange = json.percentChange24h
    }
    
    static let empty = LWModelMarketCapResult(withJSON: [:])
}

fileprivate extension Dictionary where Key == AnyHashable {
    var symbol: String {
        return self["symbol"] as? String ?? ""
    }
    
    var priceUsd: Decimal {
        guard let price = self["price_usd"] as? String, let priceDecimal = price.decimalValue else {
            return 0.0
        }
        
        return priceDecimal
    }
    
    var marketCapUsd: Decimal {
        guard let marketCapUsd = self["market_cap_usd"] as? String, let marketCapUsdDecimal = marketCapUsd.decimalValue else {
            return 0.0
        }
        
        return marketCapUsdDecimal
    }
    
    var percentChange24h: Decimal {
        guard let percentChange24h = self["percent_change_24h"] as? String, let percentChange24Decimal = percentChange24h.decimalValue else {
            return 0.0
        }
        
        return percentChange24Decimal
    }
}
