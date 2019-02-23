//
//  LWAssetModel+Extensions.swift
//  WalletCoreTests
//
//  Created by Georgi Stanev on 4.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
@testable import WalletCore

extension LWAssetModel {
    convenience init(assetId: String) {
        self.init(json: [
            "Id": assetId,
            "DisplayId": assetId,
            "Name": assetId
        ])
    }
    
    convenience init(assetId: String, accuracy: NSNumber) {
        self.init(json: [
            "Id": assetId,
            "DisplayId": assetId,
            "Name": assetId,
            "Accuracy": accuracy
            ])
    }
}
