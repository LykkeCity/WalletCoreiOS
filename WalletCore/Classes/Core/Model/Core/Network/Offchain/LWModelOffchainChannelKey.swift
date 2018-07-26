//
//  LWModelOffchainChannelKey.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public struct LWModelOffchainChannelKey {
    public let key: String?

    init(withJSON json: [AnyHashable: Any]) {
        self.key = json["Key"] as? String
    }
}
