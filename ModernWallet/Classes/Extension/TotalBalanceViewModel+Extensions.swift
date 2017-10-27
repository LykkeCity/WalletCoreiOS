//
//  TotalBalanceViewModel+Extensions.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 27.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore
import RxSwift

extension TotalBalanceViewModel {
    convenience init() {
        self.init(refresh: Observable<Void>.interval(10.0))
    }
}
