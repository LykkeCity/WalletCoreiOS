//
//  BuyStep1CellViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/25/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class BuyStep1CellViewModel {
    typealias that = BuyStep1CellViewModel
    public typealias Dependency = (authManager: LWRxAuthManager, currencyExchanger: CurrencyExchanger)

    public let model: LWAssetPairModel
    public let mainAssetId: String

    public let assetPairCodes: Driver<String>
    public let price: Driver<String>
    public let change: Driver<String>
    public let capitalization: Driver<String>
    public let iconUrl: Driver<URL?>

    public init(
        model: LWAssetPairModel,
        baseAsset: LWAssetModel,
        rates: Observable<[LWAssetPairRateModel]>,
        assetPairs: Observable<[LWAssetPairModel]>,
        market: Observable<[LWMarketModel]>,
        dependency: Dependency
    ) {
        self.model = model
        self.mainAssetId = model.baseAssetId == baseAsset.identity ? model.quotingAssetId : model.baseAssetId

        let assetObservable = dependency.authManager.allAssets.request(byId: mainAssetId)
            .filterSuccess()
            .filterNil()

        assetPairCodes = assetObservable
            .map {$0.displayFullName}
            .asDriver(onErrorJustReturn: "")

        price = assetObservable
            .exchange(forAmount: 1, currencyExchanger: dependency.currencyExchanger)
            .asDriver(onErrorJustReturn: "")

        change = rates
            .map {$0.first {$0.identity == model.identity}}
            .mapToChange()
            .asDriver(onErrorJustReturn: "")

        capitalization = market
            .map {$0.first {$0.assetPair == model.identity}}
            .mapToVolume24h(withBaseAsset: baseAsset, assetPairs: assetPairs, dependency: dependency)
            .asDriver(onErrorJustReturn: "")

        iconUrl = dependency.authManager.allAssets
            .request(byId: mainAssetId)
            .filterSuccess()
            .map {$0?.iconUrl}
            .asDriver(onErrorJustReturn: nil)
    }
}

fileprivate extension ObservableType where Self.E == LWAssetModel {

    /// Exchange an amount
    ///
    /// - Parameters:
    ///   - amount: <#amount description#>
    ///   - currencyExchanger: <#currencyExchanger description#>
    /// - Returns: <#return value description#>
    func exchange(forAmount amount: Double = 1.0, currencyExchanger: CurrencyExchanger) -> Observable<String> {
        return
            flatMap {(model: LWAssetModel) -> Observable<(baseAsset: LWAssetModel, amount: Decimal)?> in
                return currencyExchanger.exchangeToBaseAsset(amount: 1, from: model, bid: false)
            }
            .map {data -> String? in
                guard let data = data else {return nil}
                return data.amount.convertAsCurrencyWithSymbol(asset: data.baseAsset)
            }
            .replaceNilWith("")
            .startWith("")
    }
}

fileprivate extension ObservableType where Self.E == LWAssetPairRateModel? {
    func mapToChange() -> Observable<String> {
        return
            map {assetPairModel -> String? in
                guard let change = assetPairModel?.pchng else {return nil}
                return NumberFormatter.percentInstanceWithSign.string(from: change)
            }
            .replaceNilWith("")
            .startWith("")
    }
}

fileprivate extension ObservableType where Self.E == LWMarketModel? {
    func mapToVolume24h(
        withBaseAsset baseAsset: LWAssetModel,
        assetPairs: Observable<[LWAssetPairModel]>,
        dependency: BuyStep1CellViewModel.Dependency
    ) -> Observable<String> {

        return Observable.combineLatest(filterNil(), assetPairs) {(market: $0, assetPairs: $1)}
            //map to volume24H and pair that match market
            .map {data in
                data.assetPairs.first {$0.identity == data.market.assetPair}.map {(
                    volume24H: data.market.volume24H.decimalValue,
                    pair: $0
                )}
            }
            .filterNil()
            //map to volume24H and quotingAsset
            .flatMap {data -> Observable<(asset: LWAssetModel, volume24H: Decimal)> in
                return dependency.authManager.allAssets
                    .request(byId: data.pair.quotingAssetId)
                    .filterSuccess()
                    .filterNil()
                    .map {(
                        asset: $0,
                        volume24H: data.volume24H
                    )}
            }
            // exchange volume24H for base asset
            .flatMap {data -> Observable<Decimal?> in
                return dependency.currencyExchanger.exchange(amount: data.volume24H, from: data.asset, to: baseAsset, bid: false)
            }
            .map {$0?.convertAsCurrency(asset: baseAsset)}
            .replaceNilWith("")
            .startWith("")
    }
}
