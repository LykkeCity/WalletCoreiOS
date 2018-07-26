//
//  LWPacketOffchainTrade.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/18/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class LWPacketOffchainTrade: LWAuthorizePacket {

    public struct Body {
        let asset: String
        let assetPair: String
        let prevTempPrivateKey: String
        let volume: Decimal
    }

    public var body: Body
    public var model: LWModelOffchainResult?

    public init(body: Body, observer: Any) {
        self.body = body
        super.init()
        self.observer = observer
    }

    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }

    override public func parseResponse(_ response: Any!, error: Error!) {
        super.parseResponse(response, error: error)
        guard !isRejected else {return}

        if let result = self.getResut() {
            model = LWModelOffchainResult(withJSON: result)
        }
    }

    override public var params: [AnyHashable: Any]! {
        return [
            "Asset": body.asset,
            "AssetPair": body.assetPair,
            "PrevTempPrivateKey": body.prevTempPrivateKey,
            "Volume": body.volume
        ]
    }

    override public var urlRelative: String! {
        return "offchain/trade"
    }

    override public var type: GDXRESTPacketType {
        return .POST
    }
}
