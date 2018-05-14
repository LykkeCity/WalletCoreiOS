//
//  LWPacketAssetDisclaimersGet.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10.05.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public class LWPacketAssetDisclaimersGet: LWAuthorizePacket {
    
    public var assetDisclaimers: [LWModelAssetDisclaimer]? = nil
    
    public init(observer: Any) {
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        super.parseResponse(response, error: error)
        
        guard !isRejected else{ return }
        
        if let result = self.getResut()["Disclaimers"] as? [[AnyHashable: Any]]  {
            assetDisclaimers = result.map{ LWModelAssetDisclaimer(withJSON: $0) }
        }
    }
    
    override public var urlRelative: String! {
        return "AssetDisclaimers"
    }
    
    override public var type: GDXRESTPacketType {
        return .GET
    }
}
