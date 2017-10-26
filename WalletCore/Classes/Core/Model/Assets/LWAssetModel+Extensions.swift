//
//  LWAssetModel+Extensions.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/21/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

public extension LWAssetModel {
    func getPairId(withAsset asset: LWAssetModel) -> String {
        return "\(identity ?? "")\(asset.identity ?? "")"
    }
    
    /// Proxy to iconUrlString
    public var iconUrl: URL? {
        guard let identity = self.identity else {return nil}
        return URL(string: "https://lkefiles.blob.core.windows.net/images/modern_wallet_icons/\(identity).png")
    }
    
    public var displayFullName: String {
        return fullName ?? name ?? ""
    }
    
    public var displayName: String {
        return name ?? fullName ?? ""
    }
}
