//
//  KYCDocumentStatus+Extensions.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore

extension KYCDocumentStatus {
    var buttonText: String {
        if case .empty = self {
            return Localize("kyc.process.shoot")
        }
        
        return Localize("kyc.process.reshoot")
    }
    
    var image: UIImage? {
        
        switch self {
        case .empty: return nil
        case .uploaded: return #imageLiteral(resourceName: "kycIconUploaded")
        case .approved: return #imageLiteral(resourceName: "kycIconApproved")
        case .rejected: return #imageLiteral(resourceName: "kycIconDeclined")
        }
    }
    
    var isUploaded: Bool {
        if case .uploaded = self {return true}
        return false
    }
    
    var isRejected: Bool {
        if case .rejected = self {return true}
        return false
    }
    
    var isUploadedOrApproved: Bool {
        return [.uploaded, .approved].contains(self)
    }
}
