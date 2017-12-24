//
//  BuyStep1ViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/25/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

open class BuyStep1ViewModel {
    typealias that = BuyStep1ViewModel
    public typealias Dependency = (authManager: LWRxAuthManager, currencyExchanger: CurrencyExchanger)
    
    /// Filtered collection of view models according currency filter
    public let cellViewModels: Driver<[BuyStep1CellViewModel]>
    
    /// Loading indicator
    public let loading: LoadingViewModel
    
    /// Currency filter Driver
    public let currencyFilter: Driver<CurrencyType>
    
    public let selectCurrencyLabel: Driver<String>
    
    private let disposeBag = DisposeBag()
    
    public init(filter inputFilter: Observable<CurrencyType>, dependency: Dependency) {
        let pairsObservable = dependency.authManager.assetPairs.request()
        let assetPairRatesObservable = dependency.authManager.assetPairRates.request(withParams: true)
        let marketObservable = dependency.authManager.market.request()
        
        let viewModels = Variable<[BuyStep1CellViewModel]>([])
        
        pairsObservable
            .bind(
                toViewModels: viewModels,
                assetPairRates: assetPairRatesObservable,
                assetPairs: pairsObservable,
                market: marketObservable,
                dependency: dependency
            )
            .disposed(by: disposeBag)
        
        let filterObservable = inputFilter.startWith(.all).shareReplay(1)
        
        currencyFilter = filterObservable.asDriver(onErrorJustReturn: .all)
        
        cellViewModels = filterObservable
            .withLatest(fromViewModels: viewModels.asObservable().filter{$0.isNotEmpty})
            .flatMapToAssets(dependency: dependency)
            .filterByCurrencyType()
            .asDriver(onErrorJustReturn: [])
        
        selectCurrencyLabel = filterObservable
            .mapToSelectString()
            .asDriver(onErrorJustReturn: "")
        
        loading = LoadingViewModel([
            assetPairRatesObservable.isLoading(),
            pairsObservable.isLoading(),
            marketObservable.isLoading()
        ])
    }
    
    public enum CurrencyType{
        case crypto
        case fiat
        case all
    }
}

public extension BuyStep1ViewModel.CurrencyType {
    public func isCrypto() -> Bool {
        if case .crypto = self {return true}
        return false
    }
    
    public func isFiat() -> Bool {
        if case .fiat = self {return true}
        return false
    }
    
    public func isAll() -> Bool {
        if case .all = self {return true}
        return false
    }
}

fileprivate extension Array where Element == BuyStep1CellViewModel {

    /// Filter view models by currency type.
    ///
    /// - Parameters:
    ///   - type: Type used for filtering
    ///   - assets:
    /// - Returns: New collection filtered by currency filter. 
    /// If .crypto will include only view models where its mainAsset blockchainDeposit is true
    /// If .fiat will include only view models where its mainAsset blockchainDeposit is false
    /// If .all will return the same collection with no filtering
    func filter(byType type: BuyStep1ViewModel.CurrencyType, withAssets assets: [LWAssetModel]) -> [Element] {
        return filter{viewModel in
            guard let asset = (assets.first{$0.identity == viewModel.mainAssetId}) else {return false}
            
            switch type {
                case .crypto: return asset.blockchainDeposit
                case .fiat: return !asset.blockchainDeposit
                case .all: return true
            }
        }
    }
}

fileprivate extension ObservableType where Self.E == (baseAsset: LWAssetModel, assetPairs: [LWAssetPairModel]) {
    
    /// Filter asset pair models where either one of them is base asset
    ///
    /// - Returns:
    func filterByBaseAsset() -> Observable<(baseAsset: LWAssetModel, assetPairs: [LWAssetPairModel])> {
        return map{data -> (baseAsset: LWAssetModel, assetPairs: [LWAssetPairModel]) in
            let assetPairs = data.assetPairs.filter{(assetPair: LWAssetPairModel) in
                return [assetPair.quotingAssetId].contains(data.baseAsset.identity)
            }
            
            return (
                baseAsset: data.baseAsset,
                assetPairs: assetPairs
            )
        }
    }
}

// MARK:- cellViewModels Operators
fileprivate extension ObservableType where Self.E == BuyStep1ViewModel.CurrencyType {
    func withLatest(fromViewModels viewModels: Observable<[BuyStep1CellViewModel]>)
    -> Observable<(type: BuyStep1ViewModel.CurrencyType, viewModels: [BuyStep1CellViewModel])> {
        return Observable.combineLatest(self, viewModels) {(
            type: $0,
            viewModels: $1
        )}
    }
}

fileprivate extension ObservableType where Self.E == (type: BuyStep1ViewModel.CurrencyType, viewModels: [BuyStep1CellViewModel]) {
    func flatMapToAssets(dependency: BuyStep1ViewModel.Dependency) ->
        Observable<(
            type: BuyStep1ViewModel.CurrencyType,
            viewModels: [BuyStep1CellViewModel],
            assets: [LWAssetModel]
        )> {
            return flatMapLatest{ data in
                return dependency.authManager.allAssets.request()
                    .filterSuccess()
                    .map{(
                        type: data.type,
                        viewModels: data.viewModels,
                        assets: $0
                    )}
            }
    }
}

fileprivate extension ObservableType where Self.E == (type: BuyStep1ViewModel.CurrencyType, viewModels: [BuyStep1CellViewModel], assets: [LWAssetModel]) {
    func filterByCurrencyType() -> Observable<[BuyStep1CellViewModel]> {
        return map{type, viewModels, assets in
            return viewModels.filter(byType: type, withAssets: assets)
        }
    }
}

// MARK: - selectCurrencyLabel
fileprivate extension ObservableType where Self.E == BuyStep1ViewModel.CurrencyType {
    func mapToSelectString() -> Observable<String> {
        return Observable.of(
            filter{$0.isFiat()}.map{_ in Localize("buy.newDesign.selectFiat")},
            filter{$0.isCrypto()}.map{_ in Localize("buy.newDesign.selectCrypto")},
            filter{$0.isAll()}.map{_ in Localize("buy.newDesign.selectCurrency")}
        ).merge()
    }
}


// MARK: - Binings
fileprivate extension ObservableType where Self.E == ApiResultList<LWAssetPairModel> {
    
    /// Bind asset pairs to viewModels as filtering by base asset
    ///
    /// - Parameters:
    ///   - viewModels: View Models you want to bind to
    ///   - assetPairs: Asset pairs used in BuyStep1CellViewModel
    ///   - market:
    ///   - dependency: Dependency classes
    /// - Returns: Disposable as a result from the binding
    func bind(
        toViewModels viewModels: Variable<[BuyStep1CellViewModel]>,
        assetPairRates: Observable<ApiResultList<LWAssetPairRateModel>>,
        assetPairs: Observable<ApiResultList<LWAssetPairModel>>,
        market: Observable<ApiResultList<LWMarketModel>>,
        dependency: BuyStep1ViewModel.Dependency
    ) -> Disposable {
            return filterSuccess()
            .flatMap{assetPairs in dependency.authManager.baseAsset.request().filterSuccess().map{(
                baseAsset: $0,
                assetPairs: assetPairs
            )}}
            .filterByBaseAsset()
            .map{data in data.assetPairs.map{
                return BuyStep1CellViewModel(
                    model: $0,
                    baseAsset: data.baseAsset,
                    rates: assetPairRates.filterSuccess(),
                    assetPairs: assetPairs.filterSuccess(),
                    market: market.filterSuccess(),
                    dependency: dependency
                )
            }}
            .bind(to: viewModels)
    }
}
