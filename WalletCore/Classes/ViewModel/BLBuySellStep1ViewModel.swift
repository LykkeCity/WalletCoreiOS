//
//  BLBuySellViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 9/11/17.
//
//

import UIKit
import RxSwift
import RxCocoa


open class BLBuySellStep1ViewModel {

    typealias that = BLBuySellStep1ViewModel
    typealias CombinedObservable = Observable<(asset: LWAssetModel, units: Decimal, wallet: LWSpotWallet, bid: Bool)>
    typealias AssetUnitsObservable = Observable<(asset: LWAssetModel, units: Decimal, bid: Bool)>
    
    public typealias Input = (
        units:      Observable<Decimal>,
        asset:      Observable<LWAssetModel>,
        wallet:     Observable<LWSpotWallet>,
        bid:        Observable<Bool>
    )
    
    private let input: Input
    
    //MARK:- output properties
    public let assetName: Driver<String>
    //public let asset2Name: Driver<String>
    public let unitsInBaseAsset: Driver<String>
    public let walletAssetCode: Driver<String>
    public let price: Driver<String>
    public let priceInBaseAsset: Driver<String>
    public let walletTotal: Driver<String>
    public let walletTotalAv: Driver<String>
    public let walletTotalInBaseAsset: Driver<String>
    public let currentPriceCurrencyInBaseAsset: Driver<String>
    public let nonEmptyWallets: Observable<[LWSpotWallet]>
    
    public init(input: Input, currencyExchanger: CurrencyExchanger, authManager:LWRxAuthManager = LWRxAuthManager.instance) {
        self.input = input
        
        let combinedObservable =
            Observable.combineLatest(input.asset, input.units, input.wallet, input.bid){(asset: $0, units: $1, wallet: $2, bid: $3)}
                .shareReplay(1)
        
        let assetUnitsObservable =
            Observable.combineLatest(input.asset, input.units, input.bid){(asset: $0, units: $1, bid: $2)}
                .shareReplay(1)
        
        self.unitsInBaseAsset = assetUnitsObservable
            .mapToUnitsInBase(currencyExchanger: currencyExchanger)
            .asDriver(onErrorJustReturn: "")
        
        self.walletAssetCode = input.wallet
            .mapToWalletAssetCode()
            .asDriver(onErrorJustReturn: "")
        
        self.price = combinedObservable
            .mapToPrice(currencyExchanger: currencyExchanger)
            .asDriver(onErrorJustReturn: "")
        
        self.priceInBaseAsset = combinedObservable
            .mapToPriceInBase(currencyExchanger: currencyExchanger)
            .asDriver(onErrorJustReturn: "")
        
        self.walletTotal = input.wallet
            .mapToTotal()
            .asDriver(onErrorJustReturn: "")
        
        self.walletTotalAv = input.wallet
            .mapToTheTotalAv()
            .asDriver(onErrorJustReturn: "")
        
        self.walletTotalInBaseAsset = input.wallet
            .mapToTotalInBase(authManager: authManager)
            .asDriver(onErrorJustReturn: "")
        
        self.currentPriceCurrencyInBaseAsset = combinedObservable
            .mapToPriceInBase(currencyExchanger: currencyExchanger, amount: 1.0)
            .asDriver(onErrorJustReturn: "")
        
        self.nonEmptyWallets = authManager.lykkeWallets.requestNonEmptyWallets().filterSuccess()
        
        self.assetName = input.asset
            .mapToTheFullName()
            .asDriver(onErrorJustReturn: "")
    }
    
    private static func getCurrentPriceCurrencyInBaseAsset(
        totalCurrency: Decimal,
        combinedObservable: CombinedObservable,
        currencyExchanger: CurrencyExchanger
        ) -> Driver<String> {
        
        return combinedObservable
            .flatMapLatest{combinedData in currencyExchanger.exchangeToBaseAsset(
                amount: totalCurrency, from: combinedData.wallet.asset, bid: combinedData.bid
                )}
            .map{ data -> String? in
                guard let data = data else {return nil}
                return data.amount.convertAsCurrency(asset: data.baseAsset)
            }
            .replaceNilWith("Not Available")
            .asDriver(onErrorJustReturn: "")
        
    }
}


extension ObservableType where Self.E == LWAssetModel {
    func mapToTheFullName() -> Observable<String> {
        //        return map{$0.fullName}.replaceNilWith("")
        return map{$0.name}.replaceNilWith("")
    }
}
extension ObservableType where Self.E == LWSpotWallet {
    func mapToTheTotalAv() -> Observable<String> {
        //return map{$0.balance.decimalValue.convertAsCurrencyStrip(asset: $0.asset) + " AV"}
        return
            map{$0.asset.identity}
    }
}
