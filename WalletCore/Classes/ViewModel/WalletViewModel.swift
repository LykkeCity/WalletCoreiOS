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
    
    public let assetObservable: Observable<LWAssetModel>
    public let baseAssetObservable: Observable<LWAssetModel>

    public init(
        wallet: Observable<LWSpotWallet>,
        dependency: (
            currencyExchanger: CurrencyExchanger,
            authManager: LWRxAuthManager
        )
    ) {
        let baseAssetResponseObservable = dependency.authManager.baseAsset.requestBaseAssetGet()
            .shareReplay(1)
        
        let mainInfoObservable = Observable<Int>
            .interval(5, scheduler: MainScheduler.instance)
            .startWith(0)
            .flatMap{_ in dependency.authManager.mainInfo.requestMainScreenInfo(withAssetObservable: baseAssetResponseObservable)}
            .filterSuccess()
            .shareReplay(1)
        
        assetObservable = wallet.map{$0.asset}.filterNil()
        
        baseAssetObservable = baseAssetResponseObservable.filterSuccess()
        
        assetIconUrl = assetObservable
            .map { $0.iconUrl }
            .asDriver(onErrorJustReturn: nil)
            .startWith(nil)
        
        assetName = assetObservable
            .map { $0.displayFullName }
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        assetAmount = Observable.combineLatest(wallet, assetObservable) { (wallet: $0, asset: $1) }
            .map { $0.wallet.balance.decimalValue.convertAsCurrencyWithSymbol(asset: $0.asset) }
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        percent = Observable.combineLatest(wallet, mainInfoObservable) { (assetAmount: $0.amountInBase.doubleValue, totalAmount: $1.mainInfo.totalBalance.doubleValue) }
            .map { $0.totalAmount == 0 ? 0.0 : $0.assetAmount / $0.totalAmount * 100.0 }
            .map { String(format: "%.2f %%", $0) }
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        assetCode = assetObservable
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

