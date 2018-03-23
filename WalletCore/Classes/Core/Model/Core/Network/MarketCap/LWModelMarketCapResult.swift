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
    public let percentChange: Double
    
    init(withJSON json: [AnyHashable: Any]) {
        self.symbol = json["symbol"] as? String ?? ""
        self.price = json["price_usd"] as? Decimal ?? 0.00
        self.marketCap = json["market_cap_usd"] as? Decimal ?? 0.00
        self.percentChange = json["percent_change_24h"] as? Double ?? 0.00
    }
    
    static let empty = LWModelMarketCapResult(withJSON: [:])
}
