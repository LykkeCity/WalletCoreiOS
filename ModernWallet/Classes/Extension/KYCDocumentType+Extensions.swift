//
//  KYCDocumentType+Extensions.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore

extension KYCDocumentType {
    static func find(byIndex index: Int) ->  KYCDocumentType? {
        switch index {
        case 0:
            return .selfie
        case 1:
            return .idCard
        case 2:
            return .proofOfAddress
        default:
            return nil
        }
    }
    
    var index: Int {
        switch self {
        case .selfie:
            return 0
        case .idCard:
            return 1
        case .proofOfAddress:
            return 2
        }
    }
    
    var failedPhotoTitle: String {
        switch self {
        case .selfie:
            return "SELFIE".localizedUppercase
        case .idCard:
            return "Photo of your passport or another Id".localizedUppercase
        case .proofOfAddress:
            return "Photo of your proof of address".localizedUppercase
        }
    }
    
    var next: KYCDocumentType? {
        return KYCDocumentType.find(byIndex: index + 1)
    }
}
