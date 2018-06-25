//
//  LWPacketAssetDisclaimersApprove.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10.05.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public class LWPacketAssetDisclaimersApprove: LWAuthorizePacket {
    
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
    
    override public var urlRelative: String! {
        return "AssetDisclaimers/\(disclaimerId)/approve"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }
}
