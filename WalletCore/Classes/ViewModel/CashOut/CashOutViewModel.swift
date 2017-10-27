//
//  CashOutViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 27.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public typealias AmountCodePair = (amount: String, code: String)

public class CashOutViewModel {
    
    public let amountViewModel: CashOutAmountViewModel
    
    public let generalViewModel: CashOutGeneralViewModel
    
    public let bankAccountViewModel: CashOutBankAccountViewModel
    
    public let amountObservable: Observable<AmountCodePair>
    
    public let exchangeCourceObservable: Observable<AmountCodePair>
    
    public let totalObservable: Observable<AmountCodePair>
    
    private let authManager: LWRxAuthManager
    
    public init(
        amountViewModel: CashOutAmountViewModel,
        generalViewModel: CashOutGeneralViewModel,
        bankAccountViewModel: CashOutBankAccountViewModel,
        currencyExchanger: CurrencyExchanger,
        authManager: LWRxAuthManager = LWRxAuthManager.instance
    ) {
        self.amountViewModel = amountViewModel
        self.generalViewModel = generalViewModel
        self.bankAccountViewModel = bankAccountViewModel
        self.authManager = authManager
        
        let walletAndAmountObservable = Observable.combineLatest(
            amountViewModel.walletObservable,
            amountViewModel.amount.asObservable()
        )
        
        amountObservable = walletAndAmountObservable
            .mapToAmountCodePair()
        
        exchangeCourceObservable = amountViewModel.walletObservable
            .mapToExchangeInBaseCourse(currencyExchanger: currencyExchanger)
        
        totalObservable = walletAndAmountObservable
            .mapToAmountCodePairInBase(currencyExchanger: currencyExchanger)
    }
    
}

extension Observable where Element == (LWSpotWallet, Decimal) {
    
    func mapToAmountCodePair() -> Observable<AmountCodePair> {
        return self
            .map {
                let (wallet, amount) = $0
                return (amount: amount.convertAsCurrencyWithSymbol(asset: wallet.asset), code: wallet.asset.displayName)
            }
    }
    
    func mapToAmountCodePairInBase(currencyExchanger: CurrencyExchanger) -> Observable<AmountCodePair> {
        return self
            .flatMap { (data) -> Observable<(baseAsset: LWAssetModel, amaunt: Decimal)?> in
                let (wallet, amount) = data
                return currencyExchanger.exchangeToBaseAsset(amaunt: amount, from: wallet.asset, bid: false)
            }
            .filterNil()
            .map {
                let (baseAsset, amount) = $0
                return (amount: amount.convertAsCurrencyWithSymbol(asset: baseAsset), code: baseAsset.displayName)
            }
    }
    
}

extension Observable where Element == LWSpotWallet {

    func mapToExchangeInBaseCourse(currencyExchanger: CurrencyExchanger) -> Observable<AmountCodePair> {
        return self
            .flatMap { (wallet) -> Observable<(baseAsset: LWAssetModel, amaunt: Decimal)?> in
                return currencyExchanger.exchangeToBaseAsset(amaunt: 1, from: wallet.asset, bid: false)
            }
            .filterNil()
            .map {
                let (baseAsset, amount) = $0
                return (amount: amount.convertAsCurrencyWithSymbol(asset: baseAsset), code: baseAsset.displayName)
        }
    }
    
}
