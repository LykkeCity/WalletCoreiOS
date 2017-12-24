//
//  PledgeModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 11/29/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public struct PledgeModel {
    public let footprint: Int
    public let netPositiveValue: Int
    
    public init(withJSON json: [AnyHashable: Any]) {
        self.footprint = json["CO2Footprint"] as? Int ?? 0
        self.netPositiveValue = json["ClimatePositiveValue"] as? Int ?? 0
    }
}
