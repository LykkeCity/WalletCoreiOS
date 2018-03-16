//
//  LWModelMarketCapResult.swift
//  WalletCore
//
//  Created by Vasil Garov on 6.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public struct LWModelMarketCapResult {
    public let symbol: String
    public let price: Decimal
    public let marketCap: Decimal
    public let percentChange: Double
    
    init(withJSON json: [AnyHashable: Any]) {
        self.symbol = json["symbol"] as? String ?? ""
        self.price = json["price_usd"] as? Decimal ?? 0.00
        self.marketCap = json["market_cap_usd"] as? Decimal ?? 0.00
        self.percentChange = json["percent_change_24h"] as? Double ?? 0.00
    }
    
    static let empty = LWModelMarketCapResult(withJSON: [:])
}
