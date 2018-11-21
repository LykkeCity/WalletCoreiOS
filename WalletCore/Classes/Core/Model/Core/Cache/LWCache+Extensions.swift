//
//  LWCache+Extensions.swift
//  WalletCore
//
//  Created by Georgi Stanev on 3.11.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

extension LWCache {
    public func getAsset(byId id: String) -> LWAssetModel? {
        return getAllAssets().first{ $0.identity == id }
    }
    
    public func getAsset(byDisplayId id: String) -> LWAssetModel? {
        return getAllAssets().first{ $0.displayId == id }
    }
    
    public func getAllAssets() -> [LWAssetModel] {
        return (allAssets as? [LWAssetModel]) ?? []
    }
}
