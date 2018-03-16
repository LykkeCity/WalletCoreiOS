//
//  LWPacketMarketCap.swift
//  WalletCore
//
//  Created by Vasil Garov on 6.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public class LWPacketMarketCap: LWPacket {
    
    public struct Body {
        let startIndex: Int
        let limit: Int
    }
    
    public var body: Body
    public var models: [LWModelMarketCapResult] = []
    
    public init(body: Body, observer: Any) {
        self.body = body
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        //super.parseResponse(response, error: error)
        
        guard error == nil else { return }
        
        guard let array = response as? [[AnyHashable: Any]] else { return }

        models = array.map{ LWModelMarketCapResult(withJSON: $0) }
    }
    
    override public var urlBase: String! {
        return "https://api.coinmarketcap.com/v1/ticker/"
    }
    
    override public var urlRelative: String! {
        return "?start=\(body.startIndex)&limit=\(body.limit)"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }
}
