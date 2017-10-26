//
//  LWPacketOffchainFinalizetransfer.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public class LWPacketOffchainFinalizetransfer: LWAuthorizePacket {
    public struct Body {
        let transferId: String
        let clientRevokePubKey: String
        let clientRevokeEncryptedPrivateKey: String
        let signedTransferTransaction: String
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
            "TransferId": body.transferId,
            "ClientRevokePubKey": body.clientRevokePubKey,
            "ClientRevokeEncryptedPrivateKey": body.clientRevokeEncryptedPrivateKey,
            "SignedTransferTransaction": body.signedTransferTransaction
        ]
    }
    
    override public var urlRelative: String! {
        return "offchain/finalizetransfer"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }
}
