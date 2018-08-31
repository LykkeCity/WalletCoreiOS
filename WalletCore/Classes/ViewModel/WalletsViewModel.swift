//
//  WalletsViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/6/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public typealias WalletsInfoData = (
    asset: LWAssetModel,
    wallets: [LWSpotWallet],
    assets: [LWAssetModel],
    totalBalance: Decimal
)

open class WalletsViewModel {
    public var wallets: Observable<[Variable<Asset>]>
    public var loadingViewModel: LoadingViewModel
    
    /// Currency name from base asset.Example USD
    public let currencyName: Driver<String>
    
    /// User balance based on all non empty wallets
    public let totalBalance: Driver<String>
    
    ///Indicate if the total balance is zero
    public let isEmpty: Driver<Bool>
    
    ///
    public let walletsInfoData: Observable<WalletsInfoData>
    
    public init(
        refreshWallets: Observable<Void>,
        authManager:LWRxAuthManager = LWRxAuthManager.instance
    ) {
        let baseAsset = authManager.baseAsset.request()
            .shareReplay(1)
        
        let nonEmptyWallets = refreshWallets
            .flatMapLatest{ _ in authManager.lykkeWallets.requestNonEmptyWallets() }
            .filterSuccess()
            .filterBadRequest()
            .shareReplay(1)
        
        let allAssets = authManager.allAssets.request()
        
        let infoObservable = Observable<WalletsInfoData>
            .combineLatest(baseAsset.filterSuccess(), nonEmptyWallets, allAssets.filterSuccess())
            {
                (
                    asset: $0,
                    wallets: $1,
                    assets: $2,
                    totalBalance: $1.calculateBalanceInBase()
                )
            }
            .shareReplay(1)
        
        self.currencyName = baseAsset
            .mapToName()
            .asDriver(onErrorJustReturn: "")
        
        self.wallets = infoObservable.mapToAssets()
        
         self.totalBalance = infoObservable
            .map { value -> String in
                return value.totalBalance.convertAsCurrency(code: "", symbol: value.asset.symbol, accuracy: Int(value.asset.accuracy))
            }
            .asDriver(onErrorJustReturn: "")
        
        self.isEmpty = infoObservable
            .map { $0.totalBalance }
            .map { $0 == 0.0 }
            .asDriver(onErrorJustReturn: true)
        
        self.walletsInfoData = infoObservable
        
        self.loadingViewModel = LoadingViewModel([
            baseAsset.isLoading(),
            allAssets.isLoading(),
            ])
    }
}

fileprivate extension ObservableType where Self.E == ApiResult<LWAssetModel> {
    func mapToName() -> Observable<String> {
        return filterSuccess()
            .map{$0.name ?? ""}
            .startWith("")
    }
}

fileprivate extension ObservableType where Self.E == WalletsInfoData {
    func mapToAssets() -> Observable<[Variable<Asset>]> {
        return map{ data in
            
            data.wallets.forEach{ wallet in
                wallet.asset = data.assets.first{ $0.identity == wallet.identity }
            }
            
            return data.wallets
                .filter{ $0.asset != nil }
                .map{ Asset(wallet: $0, baseAsset: data.asset, totalBalance: data.totalBalance) }
                .map{ Variable($0) }
            }
    }
}

public extension ObservableType where Self.E == [LWSpotWallet] {
    func filterBadRequest() -> Observable<[LWSpotWallet]> {
        return filter{ var balance = $0.calculateBalance()
            var totalBalance = $0.calculateBalanceInBase()
            return (balance > 0.0 && totalBalance == 0.0)
        }
    }
}
