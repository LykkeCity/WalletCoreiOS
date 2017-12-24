//
//  LWPacketOffchainChannelKey.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public class LWPacketOffchainChannelKey: LWAuthorizePacket {
    let assetId: String
    var model: LWModelOffchainChannelKey?
    
    public init(assetId: String, observer: Any) {
        self.assetId = assetId
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
            model = LWModelOffchainChannelKey(withJSON: result)
        }
    }
    
    override public var urlRelative: String! {
        return "offchain/channelkey?&asset=\(assetId)"
    }
    
    override public var type: GDXRESTPacketType {
        return .GET
    }
}
