//
//  RefreshTrigger.swift
//  WalletCore
//
//  Created by Georgi Stanev on 3.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public enum RefreshTrigger {
    case showLoading
    case refresh

    public var shouldShowLoading: Bool {
        if case .showLoading = self {
            return true
        }

        return false
    }
}
