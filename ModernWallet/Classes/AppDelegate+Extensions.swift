//
//  AppDelegate+Extensions.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 25.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//
import WalletCore
import RxSwift
import RxCocoa

extension AppDelegate {
    func subscribeForPendingOffchainRequests() {
        OffchainService.instance.finalizePendingRequests()
    }
}
