//
//  ReferralLinkPacket.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/1/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class ReferralLinkPacket: LWAuthorizePacket {
    
    public var model: ReferralLinkModel?
    
    public init(observer: Any) {
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        guard !isRejected, let response = response as? [AnyHashable: Any] else { return }
        
        model = ReferralLinkModel(withJSON: response)
    }
    
    override public var urlBase: String {
        return "https://\(LWKeychainManager.instance().blueAddress!)/api"
    }
    
    override public var urlRelative: String! {
        return "referralLinks/invitation"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }
    
}
