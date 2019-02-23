//
//  LWModelAssetDisclaimer.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10.05.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public typealias AssetDisclaimerId = String
public struct LWModelAssetDisclaimer {
    public let id: AssetDisclaimerId
    public let text: String
    
    init(withJSON json: [AnyHashable: Any]) {
        self.id = json["Id"] as? AssetDisclaimerId ?? ""
        self.text = json["Text"] as? String ?? ""
    }
}
