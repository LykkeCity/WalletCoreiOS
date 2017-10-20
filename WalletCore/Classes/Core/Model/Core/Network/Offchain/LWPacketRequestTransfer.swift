//
//  LWPacketRequestTransfer.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public class LWPacketRequestTransfer: LWAuthorizePacket {

    public struct Body {
        let requestId: String
        let prevTempPrivateKey: String
        
        public init(requestId: String, prevTempPrivateKey: String) {
            self.requestId = requestId
            self.prevTempPrivateKey = prevTempPrivateKey
        }
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
            "RequestId": body.requestId,
            "PrevTempPrivateKey": body.prevTempPrivateKey
        ]
    }
    
    override public var urlRelative: String! {
        return "offchain/requestTransfer"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }
}
