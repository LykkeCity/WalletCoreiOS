//
//  PledgeGetPacket.swift
//  WalletCore
//
//  Created by Vasil Garov on 11/29/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class PledgeGetPacket: LWAuthorizePacket {
    
    public var model: PledgeModel?
    
    public init(observer: Any) {
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        guard !isRejected, let response = response as? [AnyHashable: Any] else { return }
        
        model = PledgeModel(withJSON: response)
    }
    
    //TODO: check according TEST flag
    override public var urlBase: String {
        return "https://blue-api-dev.lykkex.net/api"
    }
    
    override public var urlRelative: String! {
        return "pledges"
    }
    
    override public var type: GDXRESTPacketType {
        return .GET
    }
    
}
