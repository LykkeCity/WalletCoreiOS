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
        guard let iconUrlString = self.iconUrlString else {return nil}
        return URL(string: iconUrlString)
    }
    
    public var displayFullName: String {
        return fullName ?? name ?? ""
    }
    
    public var displayName: String {
        return name ?? fullName ?? ""
    }
}
