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
        return LWCache.assetPair(forAssetId: identity, otherAssetId: asset.identity)?.identity ?? ""
    }
    
    /// Proxy to iconUrlString
    public var iconUrl: URL? {
        guard let displayId = self.displayId else {return nil}
        return URL(string: "https://lkefiles.blob.core.windows.net/images/modern_wallet_icons/\(displayId).png")
    }
    
    public var displayFullName: String {
        return fullName ?? name ?? ""
    }
    
    public var displayName: String {
        return name ?? fullName ?? ""
    }
    
    public var isFiat: Bool {
        return !blockchainDeposit
    }
}
