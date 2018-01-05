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
    func exchange(amaunt: Decimal, from: LWAssetModel, to: LWAssetModel, bid: Bool) -> Observable<Decimal?> {
        return Observable.just(amaunt)
    }
    
    func exchangeToBaseAsset(amaunt: Decimal, from: LWAssetModel, bid: Bool) -> Observable<(baseAsset: LWAssetModel, amaunt: Decimal)?> {
        return Observable.just((
            baseAsset: from,
            amaunt: amaunt
        ))
    }
}
