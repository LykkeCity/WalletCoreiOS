//
//  LWCache+MarketCap.swift
//  WalletCore
//
//  Created by Georgi Stanev on 28.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

extension LWCache {

    /// Epiration in seconds
    private static let marketCapCacheExpiration = 300

    /// Add market caps in the cache based on body params
    ///
    /// - Parameter packet: Market Cap Packed
    func addMarketCaps(withPacket packet: LWRxAuthManagerMarketCap.Packet) {
        self.marketCaps[packet.body] = MarketCapsCacheItem(date: Date(), marketCaps: packet.models)
    }

    /// Fetch Market caps from the cache based on body params and marketCapCacheExpiration
    ///
    /// - Parameter params: Body params
    /// - Returns: Cached market caps
    func fetchMarketCaps(byParams params: LWPacketMarketCap.Body) -> [LWModelMarketCapResult]? {
        guard let marketCapsCacheItem = self.marketCaps[params] as? MarketCapsCacheItem else {
            return nil
        }

        guard marketCapsCacheItem.date.calculateDifference(toDate: Date()) <= LWCache.marketCapCacheExpiration else {
            self.marketCaps[params] = nil
            return nil
        }

        return marketCapsCacheItem.marketCaps
    }
}

private struct MarketCapsCacheItem {
    let date: Date
    let marketCaps: [LWModelMarketCapResult]
}
