//
//  TotalBalanceViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/6/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class TotalBalanceViewModel {
    
    /// Loading indicator
    public let loading: LoadingViewModel
    
    /// Currency name from base asset.Example USD
    public let currencyName: Driver<String>
    
    /// User balance based on base asset and main info.It includes trading, private balances
    public let balance: Driver<String>
    
    public let isEmpty: Driver<Bool>
    
    public let observables: (
        baseAsset: Observable<ApiResult<LWAssetModel>>,
        mainInfo: Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>>
    )
    
    public init(refresh: Observable<Void>,
                authManager:LWRxAuthManager = LWRxAuthManager.instance,
                keyChainManager: LWKeychainManager = LWKeychainManager.instance()) {
        
        let baseAssetObservable = authManager.baseAsset.request()
        let mainInfoObservable = refresh
            .throttle(2.0, scheduler: MainScheduler.instance)
            .flatMapLatest{_ in authManager.mainInfo.request(withAssetObservable: baseAssetObservable)}
            .shareReplay(1)
        
        loading = LoadingViewModel([
            mainInfoObservable.isLoading().take(2), //take just first loading true and false
            baseAssetObservable.isLoading()
        ])
        
        observables = (
            baseAsset: baseAssetObservable,
            mainInfo: mainInfoObservable
        )
        
        currencyName = baseAssetObservable
            .mapToName()
            .asDriver(onErrorJustReturn: "")
        
        balance = mainInfoObservable
            .mapToCurrency()
            .asDriver(onErrorJustReturn: "")
        
        isEmpty = mainInfoObservable
            .filterSuccess()
            .map { $0.mainInfo.totalBalance == Decimal(0) }
            .asDriver(onErrorJustReturn: false)
    }
}

//fileprivate extension ObservableType where Self.E == Int {
//    static func requestMainScreenInfo(onInterval: Int, baseAsset: Observable<ApiResult<LWAssetModel>>, authManager: LWRxAuthManager)
//        -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> {
//            return Observable<Int>.interval(RxTimeInterval(onInterval), scheduler: MainScheduler.instance)
//                .startWith(0)
//                .flatMap{_ in authManager.mainInfo.requestMainScreenInfo(withAssetObservable: baseAsset)}
//                .shareReplay(1)
//    }
//}

fileprivate extension ObservableType where Self.E == ApiResult<LWAssetModel> {
    func mapToName() -> Observable<String> {
        return filterSuccess()
            .map{$0.name ?? ""}
            .startWith("")
    }
}

fileprivate extension ObservableType where Self.E == ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)> {
    func mapToCurrency() -> Observable<String> {
        return
            filterSuccess()
            .map{(
                amaunt: $0.mainInfo.totalBalance,
                symbol: $0.asset.symbol ?? "",
                accuracy: $0.asset.accuracy
            )}
            .map{
                $0.amaunt.convertAsCurrency(code: "", symbol: $0.symbol, accuracy: Int($0.accuracy))
            }
            .startWith("")
    }
}
