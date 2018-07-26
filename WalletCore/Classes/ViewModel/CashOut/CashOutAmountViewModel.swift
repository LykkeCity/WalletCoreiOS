//
//  CashOutAmountViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 27.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class CashOutAmountViewModel {

    public let walletObservable: Observable<LWSpotWallet>

    public let amount = Variable<Decimal>(0)

    public let isValid: Observable<Bool>

    public init(
        walletObservable: Observable<LWSpotWallet>
        ) {
        self.walletObservable = walletObservable

        isValid = Observable.combineLatest(walletObservable, amount.asObservable()) {
            return (walletAmount: $0.0.balance.decimalValue, enteredAmount: $0.1)
            }
            .map { $0.enteredAmount > 0 && $0.enteredAmount <= $0.walletAmount }
    }

}
