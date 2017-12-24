//
//  LWModelCashOutSwiftResult.swift
//  WalletCore
//
//  Created by Nacho Nachev on 04/11/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public struct LWModelCashOutSwiftResult {
    public let amount: String
    public let asset: String
    public let bankName: String
    public let iban: String
    public let bic: String
    public let accountHolder: String
    
    static let empty = LWModelCashOutSwiftResult(amount: "", asset: "", bankName: "", iban: "", bic: "", accountHolder: "")
}
