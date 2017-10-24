//
//  AssetCollectionCellViewModel+Rx.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 24.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WalletCore

extension AssetCollectionCellViewModel {
    
    func driveAmount(to view: AssetAmountView) -> [Disposable] {
        return [
            cryptoAmount.drive(view.rx.amount),
            cryptoCode.drive(view.rx.code)
        ]
    }
    
    func driveAmountInBase(to view: AssetAmountView) -> [Disposable] {
        return [
            realAmount.drive(view.rx.amount),
            realCode.drive(view.rx.code)
        ]
    }
    
}
