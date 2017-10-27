//
//  CurrencyExchanger+Extensions.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 27.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore
import RxSwift


extension CurrencyExchanger {
    convenience init() {
        self.init(refresh: Observable<Void>.interval(5.0))
    }
}
