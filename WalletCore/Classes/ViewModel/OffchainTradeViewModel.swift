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
    public typealias TradeParams = (amount: Decimal?, wallet: LWSpotWallet, forAsset: LWAssetModel)
    
    public let errors: Driver<[AnyHashable: Any]>
    public let success: Driver<Void>
    public let loadingViewModel: LoadingViewModel
    public let tradeParams = Variable<TradeParams?>(nil)
    
    public init(offchainService: OffchainService, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let validatedParams = self.tradeParams.asObservable()
            .filterNil()
            .validate()
            .shareReplay(1)
        
        let tradeResult = validatedParams
            .filter{ $0 == nil } //proceed only if there are no errors
            .withLatestFrom(self.tradeParams.asObservable())
            .filterNil()
            .flatMapLatest{ params -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let amount = params.amount else {return Observable.never()}
                return offchainService.trade(amount: amount, asset: params.forAsset, forAsset: params.wallet.asset)
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
                validatedParams.filterNil(),
                tradeResult.filterError(),
                success.filter{ !$0 }.map{ _ in ["Message": "Server Error! Please try again."] }
            )
            .asDriver(onErrorJustReturn: [:])
        
        loadingViewModel = LoadingViewModel([tradeResult.isLoading()])
    }
}

fileprivate extension ObservableType where Self.E == OffchainTradeViewModel.TradeParams {
    
    func validate() -> Observable<[AnyHashable: Any]?> {
        return map{ data in
            
            guard let amount = data.amount, amount > 0.00 else {
                return ["Message": "Amount field should be not empty"]
            }
            
            guard data.wallet.balance.decimalValue != 0.0 else {
                return ["Message": String(format: "Your %@ balance is zero", data.wallet.asset.identity)]
            }
            
            guard amount <= data.wallet.balance.decimalValue else {
                return ["Message": String(format: "Your %@ balance is to low", data.wallet.asset.identity)]
            }
            
            return nil
        }
    }
}
