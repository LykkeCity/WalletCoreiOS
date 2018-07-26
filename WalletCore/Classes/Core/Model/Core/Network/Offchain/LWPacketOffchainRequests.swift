//
//  LWPacketOffchainRequests.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public class LWPacketOffchainRequests: LWAuthorizePacket {
    public var models: [LWModelOffchainRequest] = []

    public init(observer: Any) {
        super.init()
        self.observer = observer
    }

    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }

    override public func parseResponse(_ response: Any!, error: Error!) {
        super.parseResponse(response, error: error)
        guard !isRejected else {return}

        if let result = self.getResut()["Requests"] as? [[AnyHashable: Any]] {
            models = result.map {LWModelOffchainRequest(withJSON: $0)}
        }
    }

    override public var urlRelative: String! {
        return "offchain/requests"
    }

    override public var type: GDXRESTPacketType {
        return .GET
    }
}
