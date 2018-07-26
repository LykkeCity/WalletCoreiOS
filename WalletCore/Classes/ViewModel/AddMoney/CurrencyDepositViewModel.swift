//
//  CurrencyDepositViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 17.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class CurrencyDepositViewModel {
    public let result: Driver<LWPacketCurrencyDeposit>
    public let loadingViewModel: LoadingViewModel
    public let errors: Observable<[AnyHashable: Any]>

    public let assetId = Variable<String?>(nil)
    public let balanceChange = Variable<Decimal?>(nil)

    public init(trigger: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {

        let currencyDeposit = trigger
            .flatMap { [assetId, balanceChange] _ -> Observable<ApiResult<LWPacketCurrencyDeposit>> in
                guard let assetId = assetId.value else {
                    return Observable.just(ApiResult.error(withData: ["Message": "Please specify asset."]))
                }

                guard let balanceChange = balanceChange.value else {
                    return Observable.just(ApiResult.error(withData: ["Message": "Balance can't be empty"]))
                }

                return authManager.currencyDeposit.request(withParams: (assetId: assetId, balanceChange: balanceChange))
            }
            .shareReplay(1)

        errors = currencyDeposit.filterError()

        result = currencyDeposit
            .filterSuccess()
            .asDriver(onErrorJustReturn: LWPacketCurrencyDeposit(json: []))

        loadingViewModel = LoadingViewModel([currencyDeposit.isLoading()])
    }
}
