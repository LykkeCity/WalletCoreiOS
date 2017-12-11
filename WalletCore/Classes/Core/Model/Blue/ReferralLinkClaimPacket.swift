//
//  ReferralLinkClaimPacket.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/6/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class ReferralLinkClaimPacket: LWAuthorizePacket {
    
    public struct Body {
        public let referralLinkId: String
        public let isNewClient: Bool
        
        public init(referralLinkId: String, isNewClient: Bool) {
            self.referralLinkId = referralLinkId
            self.isNewClient = isNewClient
        }
    }
    
    public let body: Body
    
    public init(body: Body, observer: Any) {
        self.body = body
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public var urlBase: String {
        return "https://\(LWKeychainManager.instance().blueAddress!)/api"
    }
    
    override public var urlRelative: String! {
        return "referralLinks/invitation/\(body.referralLinkId)/claim"
    }
    
    override public var type: GDXRESTPacketType {
        return .PUT
    }
    
    override public var params: [AnyHashable : Any] {
        return body.asDictionary()
    }
    
}

extension ReferralLinkClaimPacket.Body {
    func asDictionary() -> [AnyHashable: Any] {
        return [
            "ReferalLinkId": referralLinkId,
            "IsNewClient": isNewClient
        ]
        
    }
}
