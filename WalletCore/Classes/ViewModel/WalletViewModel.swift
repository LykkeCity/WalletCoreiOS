//
//  WalletViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 23.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class WalletViewModel {
    
    public let assetIconUrl: Driver<URL?>
    public let assetName: Driver<String>
    public let percent: Driver<String>
    public let assetAmount: Driver<String>
    public let assetCode: Driver<String>
    public let inBaseAssetAmount: Driver<String>
    public let baseAssetCode: Driver<String>
    
    public let assetObservable: Observable<LWSpotWallet>
    public let baseAssetObservable: Observable<LWAssetModel>

    public init(
        refresh: Observable<Void>,
        wallet: Observable<LWSpotWallet>,
        dependency: (
            currencyExchanger: CurrencyExchanger,
            authManager: LWRxAuthManager
        )
    ) {
        let baseAssetResponseObservable = dependency.authManager.baseAsset.request()
            .shareReplay(1)
        
        let mainInfoObservable = refresh
            .flatMap{_ in dependency.authManager.mainInfo.request(withAssetObservable: baseAssetResponseObservable)}
            .filterSuccess()
            .shareReplay(1)
        
        assetObservable = wallet
        
        baseAssetObservable = baseAssetResponseObservable.filterSuccess()
        
        assetIconUrl = assetObservable
            .mapToAsset()
            .map { $0.iconUrl }
            .asDriver(onErrorJustReturn: nil)
            .startWith(nil)
        
        assetName = assetObservable
            .mapToAsset()
            .map { $0.displayFullName }
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        assetAmount = Observable.combineLatest(wallet, assetObservable) { (wallet: $0, asset: $1) }
            .map { $0.wallet.balance.decimalValue.convertAsCurrencyWithSymbol(asset: $0.asset.asset) }
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        percent = Observable.combineLatest(wallet, mainInfoObservable) { (assetAmount: $0.amountInBase.doubleValue, totalAmount: $1.mainInfo.totalBalance.doubleValue) }
            .map { $0.totalAmount == 0 ? 0.0 : $0.assetAmount / $0.totalAmount * 100.0 }
            .map { String(format: "%.2f %%", $0) }
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        assetCode = assetObservable
            .mapToAsset()
            .map { $0.displayName }
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        inBaseAssetAmount = Observable.combineLatest(wallet, baseAssetObservable) { (wallet: $0, asset: $1) }
            .map { $0.wallet.amountInBase.decimalValue.convertAsCurrencyWithSymbol(asset: $0.asset) }
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        baseAssetCode = baseAssetObservable
            .mapToIdentity()
            .asDriver(onErrorJustReturn: "")
            .startWith("")
    }
}

extension ObservableType where Self.E == LWSpotWallet {
    func mapToAsset() -> Observable<LWAssetModel> {
        return map{ $0.asset }.filterNil()
    }
}

