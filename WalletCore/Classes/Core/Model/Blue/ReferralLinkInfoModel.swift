//
//  ReferralLinkInfoModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/5/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

enum ReferralLinkType: String {
    case invitation = "Invitation"
}

public struct ReferralLinkInfoModel {
    public let type: String
    
    public init(withJSON json: [AnyHashable: Any]) {
        self.type = json["Type"] as? String ?? ""
    }
    
    public var isInvitationType: Bool {
        return type == "Invitation"
    }
}
