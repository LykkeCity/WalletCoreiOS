//
//  BuyStep3ViewModel.swift
//  LykkeWallet
//
//  Created by Bozidar Nikolic on 7/20/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class BuyStep3ViewModel {
    
    typealias that = BuyStep3ViewModel
    typealias CombinedObservable = Observable<(asset: LWAssetModel, units: Decimal, wallet: LWSpotWallet, bid: Bool)>
    typealias AssetUnitsObservable = Observable<(asset: LWAssetModel, units: Decimal, bid: Bool)>
    
    public typealias Input = (
        units:      Observable<Decimal>,
        asset:      Observable<LWAssetModel>,
        wallet:     Observable<LWSpotWallet>,
        bid:        Observable<Bool>,
        submit:     Observable<Void>
    )
    
    private let input: Input
    
    //MARK:- output properties
    public let assetName: Driver<String>
    public let unitsInBaseAsset: Driver<String>
    public let walletAssetCode: Driver<String>
    public let price: Driver<String>
    public let priceInBaseAsset: Driver<String>
    public let walletTotal: Driver<String>
    public let walletTotalAv: Driver<String>
    public let walletTotalInBaseAsset: Driver<String>
    public let currentPriceCurrencyInBaseAsset: Driver<String>
    public let nonEmptyWallets: Observable<[LWSpotWallet]>
    public let loadingViewModel: LoadingViewModel
    public let tradeResult: Observable<ApiResult<[AnyHashable: Any]>>
    
    public init(
        input: Input,
        dependency: (
            currencyExchanger: CurrencyExchanger,
            authManager: LWRxAuthManager,
            offchainManager: LWOffchainTransactionsManager,
            ethereumManager: LWEthereumTransactionsManager
        )
    ) {
        self.input = input
        
        let combinedObservable =
            Observable.combineLatest(input.asset, input.units, input.wallet, input.bid){(asset: $0, units: $1, wallet: $2, bid: $3)}
                .shareReplay(1)
        
        let assetUnitsObservable =
            Observable.combineLatest(input.asset, input.units, input.bid){(asset: $0, units: $1, bid: $2)}
                .shareReplay(1)
        
        self.unitsInBaseAsset = assetUnitsObservable
            .mapToUnitsInBase(currencyExchanger: dependency.currencyExchanger)
            .asDriver(onErrorJustReturn: "")
        
        self.walletAssetCode = input.wallet
            .mapToWalletAssetCode()
            .asDriver(onErrorJustReturn: "")
        
        self.price = combinedObservable
            .mapToPrice(currencyExchanger: dependency.currencyExchanger)
            .asDriver(onErrorJustReturn: "")
        
        self.priceInBaseAsset = combinedObservable
            .mapToPriceInBase(currencyExchanger: dependency.currencyExchanger)
            .asDriver(onErrorJustReturn: "")
        
        self.walletTotal = input.wallet
            .mapToTotal()
            .asDriver(onErrorJustReturn: "")
        
        self.walletTotalAv = input.wallet
            .mapToTotalAv()
            .asDriver(onErrorJustReturn: "")
        
        self.walletTotalInBaseAsset = input.wallet
            .mapToTotalInBase(authManager: dependency.authManager)
            .asDriver(onErrorJustReturn: "")
        
        self.currentPriceCurrencyInBaseAsset = combinedObservable
            .mapToPriceInBase(currencyExchanger: dependency.currencyExchanger, amount: 1.0, baseAsset: false)
            .asDriver(onErrorJustReturn: "")
        
        self.nonEmptyWallets = Observable.combineLatest(
            dependency.authManager.lykkeWallets.requestNonEmptyWallets().filterSuccess(),
            input.asset,
            dependency.authManager.assetPairs.request().filterSuccess()
        )
        .map{(wallets, buyAsset, assetPairs) in
            return wallets.filter{(wallet: LWSpotWallet) in
                let assetPairId = "\(buyAsset.identity!)\(wallet.asset.identity!)"
                return assetPairs.contains{$0.identity == assetPairId}
            }
        }
        
        self.assetName = input.asset
            .mapToFullName()
            .asDriver(onErrorJustReturn: "")
        
        let ethTransaction = input.submit
            .flatMapLatest{combinedObservable.take(1)}
            .filter(includeEthereum: true)
            .flatMapToAssetPairs(withAuthManager: dependency.authManager)
            .flatMapTrade(withEthereumManager: dependency.ethereumManager)
            .shareReplay(1)
        
        let offchainTransaction = input.submit
            .flatMapLatest{combinedObservable.take(1)}
            .filter(includeEthereum: false)
            .flatMapToAssetPairs(withAuthManager: dependency.authManager)
            .flatMapTrade(withOffchainManager: dependency.offchainManager)
            .shareReplay(1)
        
        self.loadingViewModel = LoadingViewModel([
            ethTransaction.isLoading(),
            offchainTransaction.isLoading()
        ])
        
        self.tradeResult = Observable.merge(ethTransaction, offchainTransaction)
    }

    private static func getCurrentPriceCurrencyInBaseAsset(
        totalCurrency: Decimal,
        combinedObservable: CombinedObservable,
        currencyExchanger: CurrencyExchanger
    ) -> Driver<String> {
        
        return combinedObservable
            .flatMapLatest{combinedData in currencyExchanger.exchangeToBaseAsset(
                amaunt: totalCurrency, from: combinedData.wallet.asset, bid: combinedData.bid
            )}
            .map{ data -> String? in
                guard let data = data else {return nil}
                return data.amaunt.convertAsCurrency(asset: data.baseAsset)
            }
            .replaceNilWith("Not Available")
            .asDriver(onErrorJustReturn: "")

    }
}

extension ObservableType where Self.E == LWAssetModel {
    func mapToFullName() -> Observable<String> {
        return map{$0.name}.replaceNilWith("")
    }
    
    func mapToIconUrl(withAuthManager authManager: LWRxAuthManager) -> Observable<URL?> {
        return flatMapLatest{asset in
            return authManager.allAssets
                .request(byId: asset.identity ?? "")
                .filterSuccess()
                .filterNil()
                .map{$0.iconUrl}
        }
    }
}

extension ObservableType where Self.E == (asset: LWAssetModel, units: Decimal, bid: Bool) {
    func mapToUnitsInBase(currencyExchanger: CurrencyExchanger) -> Observable<String> {
        return
            flatMapLatest{ assetUnits in currencyExchanger.exchangeToBaseAsset(
                amaunt: assetUnits.units, from: assetUnits.asset, bid: assetUnits.bid
            )}
            .map{data -> String? in
                guard let data = data else {return nil}
                return data.amaunt.convertAsCurrency(asset: data.baseAsset, withCode: false)
            }
            .replaceNilWith("Not Available.")
    }
}


extension ObservableType where Self.E == LWSpotWallet {
    func mapToWalletAssetCode() -> Observable<String> {
        return
            map{$0.asset.identity}
            .replaceNilWith("Not Available")
    }
    
    func mapToTotal() -> Observable<String> {
        return map{$0.balance.decimalValue.convertAsCurrencyStrip(asset: $0.asset)}
    }
    
    func mapToTotalAv() -> Observable<String> {
        return map{$0.balance.decimalValue.convertAsCurrencyStrip(asset: $0.asset) + " AV"}
    }
    
    func mapToTotalInBase(authManager: LWRxAuthManager) -> Observable<String> {
        return
            flatMapLatest{wallet in
                authManager.baseAsset
                    .request()
                    .filterSuccess()
                    .map{(wallet: wallet, baseAsset: $0)}
            }
            .map{
                $0.wallet.amountInBase.decimalValue.convertAsCurrency(asset: $0.baseAsset)
            }
    }
}

extension ObservableType where Self.E == (asset: LWAssetModel, units: Decimal, wallet: LWSpotWallet, bid: Bool) {
    func mapToPrice(currencyExchanger: CurrencyExchanger) -> Observable<String> {
        return
            flatMapLatest{combinedData in
                currencyExchanger
                    .exchange(
                        amaunt: combinedData.units,
                        from: combinedData.asset,
                        to: combinedData.wallet.asset,
                        bid: combinedData.bid
                    )
                    .map{(amaunt: $0, asset: combinedData.wallet.asset)}
            }
            .map{ data -> String? in
                guard let amaunt = data.amaunt else {return nil}
                return amaunt.convertAsCurrencyStrip(asset: data.asset)
            }
            .replaceNilWith("Not Available")
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - currencyExchanger: <#currencyExchanger description#>
    ///   - amount: <#amount description#>
    ///   - baseAsset: <#baseAsset description#>
    /// - Returns: <#return value description#>
    func mapToPriceInBase(currencyExchanger: CurrencyExchanger, amount: Decimal? = nil, baseAsset: Bool = true) -> Observable<String> {
        return
            flatMapLatest{combinedData in currencyExchanger.exchangeToBaseAsset(
                amaunt: amount ?? combinedData.units,
                from: baseAsset ? combinedData.asset : combinedData.wallet.asset,
                bid: combinedData.bid
            )}
            .map{ data -> String? in
                guard let data = data else {return nil}
                return data.amaunt.convertAsCurrency(asset: data.baseAsset)
            }
            .replaceNilWith("Not Available")
    }
    
    func filter(includeEthereum: Bool) -> Observable<(asset: LWAssetModel, units: Decimal, wallet: LWSpotWallet, bid: Bool)> {
        return filter{data in
            [data.asset.blockchainType, data.asset.blockchainType].contains(.ethereum) == includeEthereum
        }
    }
    
    func flatMapToAssetPairs(withAuthManager manager: LWRxAuthManager) -> Observable<(baseAsset: LWAssetModel, pair: LWAssetPairModel?, addressTo: String, volume: Decimal)> {
        return
            flatMapLatest{data in
                manager.assetPairs
                    .request(byId: "\(data.asset.identity ?? "")\(data.wallet.asset.identity ?? "")")
                    .filterSuccess()
                    .map{(
                        baseAsset: data.asset,
                        pair: $0,
                        addressTo: "",
                        volume: data.units
                    )}
            }
    }
}

extension ObservableType where Self.E == (baseAsset: LWAssetModel, pair: LWAssetPairModel?, addressTo: String, volume: Decimal) {
    func flatMapTrade(withEthereumManager manager: LWEthereumTransactionsManager) -> Observable<ApiResult<[AnyHashable: Any]>> {
        return flatMapLatest{data -> Observable<ApiResult<[AnyHashable: Any]>> in
            guard let pair = data.pair else {
                return Observable.just(.error(withData: ["Field": "pair", "Message": "Pair is missing"]))
            }
            
            return manager.rx.requestTrade(
                forBaseAsset: data.baseAsset,
                pair: pair,
                addressTo: "", volume: data.volume
            )
        }.shareReplay(1)
    }
    
    func flatMapTrade(withOffchainManager manager: LWOffchainTransactionsManager) -> Observable<ApiResult<[AnyHashable: Any]>> {
        return flatMapLatest{data -> Observable<ApiResult<[AnyHashable: Any]>> in
            guard let pair = data.pair else {
                return Observable.just(.error(withData: ["Field": "pair", "Message": "Pair is missing"]))
            }
            
            return manager.rx.sendSwapRequest(forAsset: data.baseAsset, pair: pair, volume: data.volume)
        }.shareReplay(1)
    }
}
