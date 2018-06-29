//
//  LWPacketOffchainCashOutSwift.swift
//  WalletCore
//
//  Created by Nacho Nachev on 3.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public class LWPacketOffchainCashOutSwift: LWAuthorizePacket {
    
    public struct Body {
        let amount: Decimal
        let asset: String
        let bankName: String
        let iban: String
        let bic: String
        let accountHolder: String
        let accountHolderAddress: String
        let accountHolderCountry: String
        let accountHolderCountryCode: String
        let accountHolderZipCode: String
        let accountHolderCity: String
        let prevTempPrivateKey: String
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
        guard !isRejected else{return}
        
        if let result = self.getResut() {
            model = LWModelOffchainResult(withJSON: result)
        }
    }
    
    override public var params: [AnyHashable : Any]! {
        return [
            "Amount": body.amount,
            "Asset": body.asset,
            "Bic": body.bic,
            "AccNumber": body.iban,
            "AccName": body.accountHolder,
            "BankName": body.bankName,
            "AccHolderAddress": body.accountHolderAddress,
            "AccHolderCountry": body.accountHolderCountry,
            "AccHolderCountryCode": body.accountHolderCountryCode,
            "AccHolderZipCode": body.accountHolderZipCode,
            "AccHolderCity": body.accountHolderCity,
            "PrevTempPrivateKey": body.prevTempPrivateKey
        ]
    }
    
    override public var urlRelative: String! {
        return "offchain/cashout/swift"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }

}
