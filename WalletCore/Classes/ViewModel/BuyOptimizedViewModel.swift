//
//  BuyOptimizedViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/9/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class BuyOptimizedViewModel {
    
    public typealias Amount = (autoUpdated: Bool, value: String)
    public typealias Asset = (autoUpdated: Bool, asset: LWAssetModel)
    public typealias Wallet = (autoUpdated: Bool, wallet: LWSpotWallet)
    typealias ExchangeData = (from: LWAssetModel, to: LWAssetModel, amount: Decimal, bid: Bool)
    
    public let buyAmount       = Variable<Amount>(Amount(autoUpdated: false, value: ""))
    public let payWithAmount   = Variable<Amount>(Amount(autoUpdated: false, value: ""))
    public let buyAsset        = Variable<Asset?>(nil)
    public let payWithWallet   = Variable<Wallet?>(nil)
    public let bid             = Variable<Bool?>(nil)
    
    public let isValidPayWithAmount: Observable<ApiResult<Void>>
    
    public let baseAssetCode: Driver<String>
    
    public let buyAssetIconURL: Driver<URL?>
    public let buyAssetName: Driver<String>
    public let buyAssetCode: Driver<String>
    public let buyAmountInBase: Driver<String>
    
    public let payWithAssetIconURL: Driver<URL?>
    public let payWithAssetName: Driver<String>
    public let payWithAssetCode: Driver<String>
    public let payWithAmountInBase: Driver<String>
    
    public let spreadPercent: Driver<String>
    public let spreadAmount: Driver<String>
    
    public let loadingViewModel: LoadingViewModel
    
    public var mainAsset: LWAssetModel? {
        guard let bid = self.bid.value else { return nil }
        return bid ? payWithWallet.value?.wallet.asset : buyAsset.value?.asset
    }
    
    public var quotingAsset: LWAssetModel? {
        guard let bid = self.bid.value else { return nil }
        return bid ? buyAsset.value?.asset : payWithWallet.value?.wallet.asset
    }
    
    public var tradeAmount: Decimal? {
        if bid.value ?? false {
            return payWithAmount.value.value.decimalValue
        }
        
        return  buyAmount.value.value.decimalValue
    }
    
    private let disposeBag = DisposeBag()
    
    public init(
        trigger: Observable<Void>,
        dependency: (
            currencyExchanger: CurrencyExchangerProtocol,
            authManager: LWRxAuthManagerProtocol
        )
    ) {
        let baseAssetRequest = dependency.authManager.baseAsset.request()
        let baseAssetObservable = baseAssetRequest
            .filterSuccess()
            .shareReplay(1)
        
        let pairsRequest = dependency.authManager.assetPairRates.request(withParams: true)
        let pairs = pairsRequest.filterSuccess()
        
        loadingViewModel = LoadingViewModel([baseAssetRequest.isLoading(),pairsRequest.isLoading()])
        baseAssetCode = baseAssetObservable
            .mapToDisplayId()
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        buyAssetIconURL = buyAsset.asObservable()
            .mapToAsset()
            .mapToIconUrl(withAuthManager: dependency.authManager)
            .asDriver(onErrorJustReturn: nil)
        
        buyAssetName = buyAsset.asObservable()
            .mapToAsset()
            .mapToFullName()
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        buyAssetCode = buyAsset.asObservable()
            .mapToAsset()
            .mapToDisplayId()
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        let buyAssetAmountObservable = Observable
            .combineLatest(
                buyAsset.asObservable().mapToAsset().debug(),
                buyAmount.asObservable().mapToValue().mapToDecimal().debug(),
                bid.asObservable().filterNil().debug()
            )
            .map{(asset: $0, units: $1, bid: $2)}
            .shareReplay(1)
        
        buyAmountInBase = buyAssetAmountObservable
            .mapToUnitsInBase(currencyExchanger: dependency.currencyExchanger)
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        payWithAssetIconURL = payWithWallet.asObservable()
            .mapToAsset()
            .mapToIconUrl(withAuthManager: dependency.authManager)
            .asDriver(onErrorJustReturn: nil)
        
        payWithAssetName = payWithWallet.asObservable()
            .mapToAsset()
            .mapToFullName()
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        payWithAssetCode = payWithWallet.asObservable()
            .mapToAsset()
            .mapToDisplayId()
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        let payWithAssetAmountObservable = Observable
            .combineLatest(
                payWithWallet.asObservable().mapToAsset().debug("GG: 12"),
                payWithAmount.asObservable().mapToValue().mapToDecimal().debug("GG: 13"),
                bid.asObservable().filterNil().debug("GG: 14")
            )
            .map{(asset: $0, units: $1, bid: $2)}
            .shareReplay(1)
        
        payWithAmountInBase = payWithAssetAmountObservable
            .mapToUnitsInBase(currencyExchanger: dependency.currencyExchanger)
            .asDriver(onErrorJustReturn: "")
            .startWith("")
        
        let spreadObservable = Observable.combineLatest(pairs,
                                                        buyAsset.asObservable(),
                                                        payWithWallet.asObservable(),
                                                        baseAssetObservable)
            .map{pairRates,buyAsset,payWithWallet,baseAsset -> (buySellPair: LWAssetPairRateModel?, sellBasePair: LWAssetPairRateModel?, baseAsset: LWAssetModel?)? in
                guard let payWithWallet = payWithWallet else {return nil}
                guard let buyAsset = buyAsset else {return nil}
                let buySellPairStr = buyAsset.asset.getPairId(withAsset: payWithWallet.wallet.asset)
                let sellBasePairStr = payWithWallet.wallet.asset.getPairId(withAsset:  baseAsset)
                return (buySellPair: pairRates.find(byPair: buySellPairStr), sellBasePair: pairRates.find(byPair: sellBasePairStr),baseAsset: baseAsset)
        }
        .shareReplay(1)
        
        
        spreadAmount = spreadObservable
            .map{data -> String? in
                guard let data = data else {return nil}
                guard let buySellPair = data.buySellPair else {return nil}
                guard let sellBasePair = data.sellBasePair else {return nil}
                guard let baseAsset = data.baseAsset else {return nil}

                let spread = abs(buySellPair.ask.doubleValue - buySellPair.bid.doubleValue)
                let sellToBaseRate = (sellBasePair.ask.doubleValue + sellBasePair.bid.doubleValue) / 2
                let spreadInBase =  Decimal(spread * sellToBaseRate)
                return spreadInBase.convertAsCurrency(asset: baseAsset, withCode: false)
            }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
        
        spreadPercent = spreadObservable
            .map{data -> String? in
                guard let data = data else {return nil}
                guard let buySellPair = data.buySellPair else {return nil}
                
                let spread = abs(buySellPair.ask.doubleValue - buySellPair.bid.doubleValue)
                let percent = (spread / buySellPair.ask.doubleValue) * 100
                return NumberFormatter.percentInstancePerise.string(from: NSDecimalNumber(decimal: Decimal(percent)))
            }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
        
        
        isValidPayWithAmount = Observable
            .combineLatest(payWithAmount.asObservable(), payWithWallet.asObservable())
            .validate()
            .skip(2) //skip 2 because payWithAmount and payWithWallet have initial values
        
        //MARK: two way amount bindings
        payWithWallet.asObservable()
            .filter(byAutoUpdated: false)
            .bind(toBuy: buyAmount, withData: self, currencyExchanger: dependency.currencyExchanger)
            .disposed(by: disposeBag)
        
        payWithAmount.asObservable()
            .filter(byAutoUpdated: false)
            .bind(toBuy: buyAmount, withData: self, currencyExchanger: dependency.currencyExchanger)
            .disposed(by: disposeBag)
        
        payWithWallet.asObservable()
            .filter(byAutoUpdated: true)
            .bind(toPayWith: payWithAmount, withData: self, currencyExchanger: dependency.currencyExchanger)
            .disposed(by: disposeBag)
        
        buyAmount.asObservable()
            .filter(byAutoUpdated: false)
            .bind(toPay: payWithAmount, withData: self, currencyExchanger: dependency.currencyExchanger)
            .disposed(by: disposeBag)
        
        buyAsset.asObservable()
            .filter(byAutoUpdated: false)
            .bind(toPayWith: payWithAmount, withData: self, currencyExchanger: dependency.currencyExchanger)
            .disposed(by: disposeBag)
    }
}

extension ObservableType where Self.E == String {
    func mapToDecimal() -> Observable<Decimal> {
        return map{$0.decimalValue}.replaceNilWith(0.0)
    }
}

fileprivate extension ObservableType where Self.E == (BuyOptimizedViewModel.Amount, BuyOptimizedViewModel.Wallet?) {
    func validate() -> Observable<ApiResult<Void>> {
        return
            map{ data -> ApiResult<Void> in
                let (amount, wallet) = data
                
                guard let amountValue = amount.value.decimalValue, amountValue > 0 else {
                    return .error(withData: ["Message": "Amount can't be zero or empty."])
                }
                
                guard let walletAmount = wallet?.wallet.balance.decimalValue else {
                    return .error(withData: ["Message": "Wallet amount is zero"])
                }
                
                guard amountValue <= walletAmount else {
                    return .error(withData: ["Message": "Please fill lower amount."])
                }
                
                return .success(withData: Void())
            }
            .shareReplay(1)
    }
}

fileprivate extension ObservableType where Self.E == BuyOptimizedViewModel.ExchangeData {
    func exchangeAmount(currencyExchanger: CurrencyExchangerProtocol) -> Observable<BuyOptimizedViewModel.Amount> {
        return flatMap{combinedData in
            currencyExchanger.exchange(
                amount: combinedData.amount,
                from: combinedData.from,
                to: combinedData.to,
                bid: combinedData.bid
            )
            .filterNil()
            .map{amount in
                guard let accuracy = combinedData.to.accuracy?.intValue else {
                    return String(amount.doubleValue)
                }
                
                return String(format: "%.\(accuracy)f", amount.doubleValue).replaceDotWithDecimalSeparator()
            }
            .map{BuyOptimizedViewModel.Amount(autoUpdated: true, value: $0)}
            .take(1)
        }
    }
}

public extension ObservableType where Self.E == BuyOptimizedViewModel.Amount {
    func mapToValue() -> Observable<String> {
        return map{$0.value}
    }
    
    func filter(byAutoUpdated autoUpdated: Bool) -> Observable<String> {
        return filter{$0.autoUpdated == autoUpdated}.mapToValue()
    }
}

fileprivate extension ObservableType where Self.E == String {
    func bind(
        toBuy buyAmount: Variable<BuyOptimizedViewModel.Amount>,
        withData viewModel: BuyOptimizedViewModel,
        currencyExchanger: CurrencyExchangerProtocol
    ) -> Disposable {
        return
            mapToDecimal()
            .distinctUntilChanged()
            .map{[weak viewModel] payWithAmount -> BuyOptimizedViewModel.ExchangeData? in
                guard let payWithAsset = viewModel?.payWithWallet.value?.wallet.asset else {return nil}
                guard let buyAsset = viewModel?.buyAsset.value?.asset else {return nil}
                guard let bid = viewModel?.bid.value else {return nil}
                
                return BuyOptimizedViewModel.ExchangeData(from: payWithAsset, to: buyAsset, amount: payWithAmount, bid: bid)
            }
            .filterNil()
            .exchangeAmount(currencyExchanger: currencyExchanger)
            .bind(to: buyAmount)
    }
    
    func bind(
        toPay payWithAmount: Variable<BuyOptimizedViewModel.Amount>,
        withData viewModel: BuyOptimizedViewModel,
        currencyExchanger: CurrencyExchangerProtocol
    ) -> Disposable {
        return
            mapToDecimal()
            .distinctUntilChanged()
            .map{[weak viewModel] buyAmount -> BuyOptimizedViewModel.ExchangeData? in
                guard let buyAsset = viewModel?.buyAsset.value?.asset else {return nil}
                guard let payWithAsset = viewModel?.payWithWallet.value?.wallet.asset else {return nil}
                guard let bid = viewModel?.bid.value else {return nil}
                
                return (from: buyAsset, to: payWithAsset, amount: buyAmount, bid: bid)
            }
            .filterNil()
            .exchangeAmount(currencyExchanger: currencyExchanger)
            .bind(to: payWithAmount)
    }
}

public extension ObservableType where Self.E == BuyOptimizedViewModel.Wallet? {
    func mapToAsset() -> Observable<LWAssetModel> {
        return map{$0?.wallet.asset}.filterNil()
    }
    
    func filter(byAutoUpdated autoUpdated: Bool) -> Observable<LWAssetModel> {
        return filter{$0?.autoUpdated == autoUpdated}.mapToAsset()
    }
}

public extension ObservableType where Self.E == BuyOptimizedViewModel.Asset? {
    func mapToAsset() -> Observable<LWAssetModel> {
        return map{$0?.asset}.filterNil()
    }
    
    func filter(byAutoUpdated autoUpdated: Bool) -> Observable<LWAssetModel> {
        return filter{$0?.autoUpdated == autoUpdated}.mapToAsset()
    }
}

fileprivate extension ObservableType where Self.E == LWAssetModel {
    func distinctUntilChangedById() -> Observable<LWAssetModel> {
        return distinctUntilChanged{new, old in new.identity == old.identity}
    }
    
    func bind(
        toBuy buyAmount: Variable<BuyOptimizedViewModel.Amount>,
        withData viewModel: BuyOptimizedViewModel,
        currencyExchanger: CurrencyExchangerProtocol
    ) -> Disposable {
        return
            distinctUntilChangedById()
            .map{[weak viewModel] payWithAsset -> BuyOptimizedViewModel.ExchangeData? in
                guard let buyAsset = viewModel?.buyAsset.value?.asset else {return nil}
                guard let payWithAmount = viewModel?.payWithAmount.value.value.decimalValue else{return nil}
                guard let bid = viewModel?.bid.value else {return nil}
                
                return BuyOptimizedViewModel.ExchangeData(from: payWithAsset, to: buyAsset, amount: payWithAmount, bid: bid)
            }
            .filterNil()
            .exchangeAmount(currencyExchanger: currencyExchanger)
            .bind(to: buyAmount)
    }
    
    func bind(
        toPayWith payWithAmount: Variable<BuyOptimizedViewModel.Amount>,
        withData viewModel: BuyOptimizedViewModel,
        currencyExchanger: CurrencyExchangerProtocol
    ) -> Disposable {
        return
            distinctUntilChangedById()
            .map{[weak viewModel] _ -> (from: LWAssetModel, to: LWAssetModel, amount: Decimal, bid: Bool)? in
                guard let buyAsset = viewModel?.buyAsset.value?.asset else {return nil}
                guard let payWithAsset = viewModel?.payWithWallet.value?.wallet.asset else {return nil}
                guard let amount = viewModel?.buyAmount.value.value.decimalValue else {return nil}
                guard let bid = viewModel?.bid.value else {return nil}
                
                return (from: buyAsset, to: payWithAsset, amount: amount, bid: bid)
            }
            .filterNil()
            .exchangeAmount(currencyExchanger: currencyExchanger)
            .bind(to: payWithAmount)
    }
}
