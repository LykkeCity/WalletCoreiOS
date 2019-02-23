//
//  Decimal+Extensions.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/13/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public extension Decimal {
    public var doubleValue: Double {
        return Double(self as NSNumber)
    }
}
