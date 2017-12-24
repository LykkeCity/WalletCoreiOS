//
//  ReferralLinkModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/1/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public struct ReferralLinkModel {
    public let url: String
    
    public init(withJSON json: [AnyHashable: Any]) {
        self.url = json["RefLinkUrl"] as? String ?? ""
    }
}
