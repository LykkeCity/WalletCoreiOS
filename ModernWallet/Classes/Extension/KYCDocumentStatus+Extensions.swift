//
//  KYCDocumentStatus+Extensions.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore

// MARK: - Utils
extension KYCDocumentStatus {
    
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

// MARK: - UIKit
extension KYCDocumentStatus {
    
    var image: UIImage? {
        
        switch self {
        case .empty: return nil
        case .uploaded: return #imageLiteral(resourceName: "kycIconUploaded")
        case .approved: return #imageLiteral(resourceName: "kycIconApproved")
        case .rejected: return #imageLiteral(resourceName: "kycIconDeclined")
        }
    }
    
    var buttonText: String {
        if case .empty = self {
            return Localize("kyc.process.shoot")
        }
        
        return Localize("kyc.process.reshoot")
    }
    
    
    var title: String {
        switch self {
        case .empty: return ""
        case .uploaded: return Localize("kyc.documentStatus.uploaded.title")
        case .approved: return Localize("kyc.documentStatus.approved.title")
        case .rejected: return ""
        }
    }
    
    var description: String {
        switch self {
        case .empty: return ""
        case .uploaded: return Localize("kyc.documentStatus.uploaded.descr")
        case .approved: return Localize("kyc.documentStatus.approved.descr")
        case .rejected: return ""
        }
    }
}
