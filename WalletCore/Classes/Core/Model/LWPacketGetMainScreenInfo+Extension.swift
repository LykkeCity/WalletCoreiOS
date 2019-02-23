//
//  LWPacketGetMainScreenInfo+Extension.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 6/30/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

extension LWPacketGetMainScreenInfo {
    
    /// Sum of trading and private balance
    var totalBalance: Decimal {
        return Decimal(tradingBalance + privateBalance)
    }
}
