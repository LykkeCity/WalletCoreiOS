//
//  PledgePostPacket.swift
//  WalletCore
//
//  Created by Vasil Garov on 11/28/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class PledgePostPacket: LWAuthorizePacket {
    
    public struct Body {
        public let footprint: Int
        public let climatePositive: Int
        
        public init(climatePositive: Int, footprint: Int) {
            self.footprint = footprint
            self.climatePositive = climatePositive
        }
    }
    
    public var body: Body
    
        public init(body: Body, observer: Any) {
            self.body = body
            super.init()
            self.observer = observer
        }
        
        required public init!(json: Any!) {
            fatalError("init(json:) has not been implemented")
        }
        
        //TODO: check according TEST flag
        override public var urlBase: String {
            return "https://blue-api-dev.lykkex.net/api"
        }
        
        override public var urlRelative: String! {
            return "pledges"
        }
        
        override public var type: GDXRESTPacketType {
            return .POST
        }
        
        override public var params: [AnyHashable : Any] {
            return body.asDictionary()
        }
}

extension PledgePostPacket.Body {
    func asDictionary() -> [AnyHashable: Any] {
        return [
            "CO2Footprint": footprint,
            "ClimatePositiveValue": climatePositive
        ]
    }
}
