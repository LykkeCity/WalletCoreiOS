//
//  ReferralLinkInfoPacket.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/5/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class ReferralLinkInfoPacket: LWAuthorizePacket {
    
    public var model: ReferralLinkInfoModel?
    
    let id: String
    
    public init(id: String, observer: Any) {
        self.id = id
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        guard !isRejected, let response = response as? [AnyHashable: Any] else { return }
        
        model = ReferralLinkInfoModel(withJSON: response)
    }
    
    override public var urlBase: String {
        return "https://\(LWKeychainManager.instance().blueAddress!)/api"
    }
    
    override public var urlRelative: String! {
        return "refLinks/id/\(id)"
    }
    
    override public var type: GDXRESTPacketType {
        return .GET
    }
    
}
