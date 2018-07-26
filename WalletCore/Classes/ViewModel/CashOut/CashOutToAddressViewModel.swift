//
//  CashOutToAddressViewModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/22/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class CashOutToAddressViewModel {
    public let amount = Variable<Decimal>(0)

    public let address = Variable("")

    public let assetId = Variable("")

    public let loadingViewModel: LoadingViewModel

    public var isValidAddressAndAmount: Driver<Bool>

    public let errors: Driver<[AnyHashable: Any]>

    public let success: Driver<String>

    public init(
        trigger: Observable<Void>,
        authManager: LWRxAuthManager = LWRxAuthManager.instance,
        cashOutService: CashOutService = CashOutService.instance
    ) {
        let cashOutResultObservable = trigger
            .flatMap { [amount, address, assetId] in
                cashOutService.cashout(to: address.value, assetId: assetId.value, amount: amount.value)
            }
            .shareReplay(1)

        self.loadingViewModel = LoadingViewModel([
            cashOutResultObservable.map { $0.isLoading }
        ])

        isValidAddressAndAmount = Driver
            .combineLatest( self.address.asDriver(), self.amount.asDriver()) {(address, amount) in
                return !address.isEmpty && amount > 0
            }

        success = cashOutResultObservable
            .map { $0.getSuccess() }
            .filterNil()
            .filter { $0 }
            .map { _ in Localize("send.newDesign.confirm.message") }
            .asDriver(onErrorJustReturn: "There was an error.")

        errors = cashOutResultObservable
            .map { $0.getError() }
            .filterNil()
            .asDriver(onErrorJustReturn: [:])
    }
}
