//
//  NotificationCenter.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 6/29/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let loggedIn = Notification.Name("loggedIn")
    static let kycDocumentsUploadedOrApproved = Notification.Name("kycDocumentsUploadedOrApproved")
}
