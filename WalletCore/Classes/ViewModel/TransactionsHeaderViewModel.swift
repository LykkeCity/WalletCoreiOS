//
//  TransactionsHeaderViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/12/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class TransactionsHeaderViewModel {
    public let asset: Variable<ApiResult<LWAssetModel>?>

    /// Balance according to given asset
    public let assetBalance: Driver<String>
    
    /// Asset name according to given asset.Example "BTC"
    public let assetShortName: Driver<String>
    
    /// Asset name according to given asset.Example: "BITCOIN"
    public let assetName: Driver<String>
    
    /// Base asset balance.Example: "($12,234.23 USD)"
    public let baseAssetBalance: Driver<String>
    
    /// Loading Indicator that collects all requests
    public let loading: LoadingViewModel
    
    public init(
        asset: Variable<ApiResult<LWAssetModel>?>,
        walletsViewModel: WalletsViewModel,
        authManager: LWRxAuthManager = LWRxAuthManager.instance
    ) {
        let assetObservable = asset.asObservable().filterNil().shareReplay(1)
        
        self.asset = asset
        
        let assetMainInfoObservable =
            authManager.mainInfo.request(withAssetObservable: assetObservable)
        
        self.loading = LoadingViewModel([
            walletsViewModel.loadingViewModel.isLoading,
            assetMainInfoObservable.isLoading()
        ])
        
        self.assetName = assetObservable
            .mapToName()
            .asDriver(onErrorJustReturn: "")
        
        self.assetShortName = assetObservable
            .mapToShortName()
            .asDriver(onErrorJustReturn: "")
        
        self.baseAssetBalance = walletsViewModel
            .mapToBaseAssetBalance()
            .asDriver(onErrorJustReturn: "")
        
        self.assetBalance = assetMainInfoObservable.filterSuccess()
            .mapToAssetBalance()
            .asDriver(onErrorJustReturn: "")
    }

}

fileprivate extension ObservableType where Self.E == ApiResult<LWAssetModel> {
    func mapToName() -> Observable<String> {
        return filterSuccess()
            .map{LWCache.asset(byId: $0.identity) ?? $0}
            .map{$0?.displayFullName ?? ""}
            .startWith("")
    }
    
    func mapToShortName() -> Observable<String> {
        return
            filterSuccess()
            .map{LWCache.asset(byId: $0.identity) ?? $0}
            .map{$0?.displayName ?? ""}
            .startWith("")
    }
}

fileprivate extension WalletsViewModel {
    func mapToBaseAssetBalance() -> Observable<String> {
        return infoData
            .map {
                $0.totalBalance.convertAsCurrency(
                code: $0.asset.name ?? "",
                symbol: $0.asset.symbol ?? "",
                accuracy: Int($0.asset.accuracy)
            )}
            .map{"(\($0))"}
            .startWith("")
    }
}

fileprivate extension ObservableType where Self.E == (mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel) {
    func mapToAssetBalance() -> Observable<String> {
        return
            map{$0.mainInfo.totalBalance.convertAsCurrency(
                code: "",
                symbol: "",
                accuracy: Int($0.asset.accuracy ?? 0)
            )}
            .startWith("")
    }
}
