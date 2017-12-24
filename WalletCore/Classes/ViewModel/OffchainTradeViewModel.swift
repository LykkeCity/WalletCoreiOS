//
//  OffchainTradeViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 27.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class OffchainTradeViewModel {
    public typealias TradeParams = (amount: Decimal?, asset: LWAssetModel, forAsset: LWAssetModel)
    
    public let errors: Driver<[AnyHashable: Any]>
    public let success: Driver<Void>
    public let loadingViewModel: LoadingViewModel
    public let tradeParams = Variable<TradeParams?>(nil)
    
    public init(offchainService: OffchainService, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let tradeResult = self.tradeParams.asObservable()
            .filterNil()
            .flatMapLatest{ params -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let amount = params.amount else {
                    return Observable.just(ApiResult.error(withData: ["Message": "Amount field should be not empty"]))
                }
                
                return offchainService.trade(amount: amount, asset: params.asset, forAsset: params.forAsset)
            }
            .shareReplay(1)
        
        let success = tradeResult
            .filterSuccess()
            .map{ offchainResult in offchainResult.order != nil }
        
        self.success = success
            .filter{ $0 }
            .map{ _ in Void() }
            .asDriver(onErrorJustReturn: Void())
        
        errors = Observable
            .merge(
                tradeResult.filterError(),
                success.filter{ !$0 }.map{ _ in ["Message": "Server Error! Please try again."] }
            )
            .asDriver(onErrorJustReturn: [:])
        
        loadingViewModel = LoadingViewModel([tradeResult.isLoading()])
    }
}
