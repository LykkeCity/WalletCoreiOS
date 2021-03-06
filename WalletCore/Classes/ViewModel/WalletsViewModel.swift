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

private typealias WalletsInfoData = (
    asset: LWAssetModel,
    wallets: [LWSpotWallet],
    assets: [LWAssetModel],
    totalBalance: Decimal
)

open class WalletsViewModel {
    /// All non-empty wallets 
    public var wallets: Observable<[Variable<Asset>]>
    
    /// Currency name from base asset.Example USD
    public let currencyName: Driver<String>
    
    /// User balance based on all non empty wallets
    public let totalBalance: Driver<String>
    
    /// Indicate if the total balance is zero
    public let isEmpty: Driver<Bool>
    
    /// The current user base asset
    public let baseAsset: Observable<LWAssetModel>
    
    /// Loading view model
    public var loadingViewModel: LoadingViewModel
    
    public init(
        refreshWallets: Observable<Void>,
        authManager:LWRxAuthManager = LWRxAuthManager.instance
    ) {
        let baseAssetRequest = authManager.baseAsset.request()
            .shareReplay(1)
        
        let baseAssetResult = baseAssetRequest.filterSuccess()
            .shareReplay(1)
        
        self.baseAsset = baseAssetResult
        
        let nonEmptyWalletsRequest = refreshWallets
            .flatMapLatest{ _ in authManager.lykkeWallets.requestNonEmptyWallets() }
            .shareReplay(1)
        
        let nonEmptyWallets = nonEmptyWalletsRequest
            .filterSuccess()
            .filterBadRequest()
            .shareReplay(1)
        
        let allAssetsRequest = authManager.allAssets.request()
            .shareReplay(1)
        
        let infoObservable = Observable<WalletsInfoData>
            .combineLatest(baseAssetResult, nonEmptyWallets, allAssetsRequest.filterSuccess())
            {
                (
                    asset: $1.findBaseAsset() ?? $0,
                    wallets: $1,
                    assets: $2,
                    totalBalance: $1.calculateBalanceInBase()
                )
            }
            .shareReplay(1)
        
        self.currencyName = nonEmptyWallets
            .map{ $0.findBaseAsset() }
            .filterNil()
            .mapToName()
            .asDriver(onErrorJustReturn: "")
        
        self.wallets = infoObservable.mapToAssets()
        
         self.totalBalance = infoObservable
            .flatMapLatest { info in
                authManager.allAssets.request(byId: info.asset.identity)
                .filterSuccess()
                .filterNil()
                .map {(asset: $0, info: info )}
            }
            .map { value -> String in
                let accuracy = value.asset.accuracy?.intValue ?? 2
                let symbol = value.info.asset.symbol ?? ""
                return value.info.totalBalance.convertAsCurrency(code: "", symbol: symbol, accuracy: accuracy)
            }
            .asDriver(onErrorJustReturn: "")
        
        self.isEmpty = infoObservable
            .map { $0.totalBalance }
            .map { $0 == 0.0 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
        
        self.loadingViewModel = LoadingViewModel([
            nonEmptyWalletsRequest.isLoading(),
            baseAssetRequest.isLoading(),
            allAssetsRequest.isLoading()
        ])
    }
}

fileprivate extension ObservableType where Self.E == LWAssetModel {
    func mapToName() -> Observable<String> {
        return map{$0.displayId ?? ""}
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
        return filter {
            let balance = $0.calculateBalance()
            let totalBalance = $0.calculateBalanceInBase()
            return !(balance > 0.0 && totalBalance == 0.0)
        }
    }
}


