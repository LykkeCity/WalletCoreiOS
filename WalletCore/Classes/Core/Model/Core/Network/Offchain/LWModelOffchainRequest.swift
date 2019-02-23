//
//  LWModelOffchainRequest.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public struct LWModelOffchainRequest {
    public let assetId: String
    public let requestId: String
    public let offchainRequestType: Int

    public init(withJSON json: [AnyHashable: Any]) {
        self.assetId = json["Asset"] as? String ?? ""
        self.requestId = json["RequestId"] as? String ?? ""
        self.offchainRequestType = json["Type"] as? Int ?? 0
    }
}
