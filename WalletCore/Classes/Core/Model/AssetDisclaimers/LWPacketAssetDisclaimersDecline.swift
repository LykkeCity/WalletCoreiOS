//
//  LWPacketAssetDisclaimersDecline.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10.05.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public class LWPacketAssetDisclaimersDecline: LWAuthorizePacket {
    
    public var result: Bool?
    public let disclaimerId: AssetDisclaimerId
    
    public init(observer: Any, disclaimerId: AssetDisclaimerId) {
        self.disclaimerId = disclaimerId
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        super.parseResponse(response, error: error)
        
        guard !isRejected else { return }
        
        if let result = self.getResut() {
            
        }
    }
    
    override public var urlRelative: String! {
        return "AssetDisclaimers/\(disclaimerId)/decline"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }
}
