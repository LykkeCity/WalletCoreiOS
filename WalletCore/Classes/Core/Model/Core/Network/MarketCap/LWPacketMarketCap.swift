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
        
        public init(startIndex: Int, limit: Int) {
            self.startIndex = startIndex
            self.limit = limit
        }
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
        
        guard error == nil, let array = response as? [[AnyHashable: Any]] else { return }
        models = array.map{ LWModelMarketCapResult(withJSON: $0) }
    }
    
    //TODO: Move to constants
    override public var urlBase: String! {
        return "https://api.coinmarketcap.com/"
    }
    
    public override var urlRelative: String {
        return "v1/ticker/"
    }
    
    public override var params: [AnyHashable : Any] {
        return [
            "start": body.startIndex,
            "limit": body.limit
        ]
    }
    
    override public var type: GDXRESTPacketType {
        return .GET
    }
}

extension LWPacketMarketCap.Body: Hashable {
    public var hashValue: Int {
        return Int("\(self.startIndex)\(limit)") ?? 0
    }
    
    public static func ==(lhs: LWPacketMarketCap.Body, rhs: LWPacketMarketCap.Body) -> Bool {
        return lhs.limit == rhs.limit && lhs.startIndex == rhs.startIndex
    }
}
