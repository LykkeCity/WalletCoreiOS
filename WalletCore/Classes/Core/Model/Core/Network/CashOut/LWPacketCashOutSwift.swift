//
//  LWPacketCashOutSwift.swift
//  WalletCore
//
//  Created by Nacho Nachev on 2.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public class LWPacketCashOutSwift: LWAuthorizePacket {
    
    public struct Body {
        let amount: Decimal
        let asset: String
        let bankName: String
        let iban: String
        let bic: String
        let accountHolder: String
        let accountHolderAddress: String
    }
    
    public var body: Body
    public var model: LWModelOffchainResult? = nil
    
    public init(body: Body, observer: Any) {
        self.body = body
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        super.parseResponse(response, error: error)
    }
    
    override public var params: [AnyHashable : Any]! {
        return [
            "Bic": body.bic,
            "AssetId": body.asset,
            "AccNumber": body.iban,
            "AccName": body.accountHolder,
            "Amount": body.amount,
            "BankName": body.bankName,
            "AccHolderAddress": body.accountHolderAddress
        ]
    }
    
    override public var urlRelative: String! {
        return "CashOutSwiftRequest"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }

}
