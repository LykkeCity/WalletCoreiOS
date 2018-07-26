//
//  LWModelOffchainOrder.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public struct LWModelOffchainOrder {
    public let id: String
    public let dateTime: String
    public let orderType: String
    public let volume: Decimal
    public let price: Decimal
    public let assetId: String
    public let assetPair: String
    public let totalCost: Decimal
    public let remainingVolume: Decimal
    public let remainingOtherVolume: Decimal

    public init(withJSON json: [AnyHashable: Any]) {
        self.id = json["Id"] as? String ?? ""
        self.dateTime = json["DateTime"] as? String ?? ""
        self.orderType = json["OrderType"] as? String ?? ""
        self.volume = json["Volume"] as? Decimal ?? 0
        self.price = json["Price"] as? Decimal ?? 0
        self.assetId = json["Asset"] as? String ?? ""
        self.assetPair = json["AssetPair"] as? String ?? ""
        self.totalCost = json["TotalCost"] as? Decimal ?? 0
        self.remainingVolume = json["RemainingVolume"] as? Decimal ?? 0
        self.remainingOtherVolume = json["RemainingOtherVolume"] as? Decimal ?? 0
    }
}
