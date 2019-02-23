//
//  CurrencyExchangerMock.swift
//  WalletCoreTests
//
//  Created by Georgi Stanev on 3.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift
@testable import WalletCore

class CurrencyExchangerMock: CurrencyExchangerProtocol {
    
    func exchange(amount amaunt: Decimal, from: LWAssetModel, to: LWAssetModel, bid: Bool) -> Observable<Decimal?> {
        return Observable.just(amaunt)
    }
    
    func exchangeToBaseAsset(amount: Decimal, from: LWAssetModel, bid: Bool) -> Observable<(baseAsset: LWAssetModel, amount: Decimal)?> {
        return Observable.just((
            baseAsset: from,
            amount: amount
        ))
    }

}
