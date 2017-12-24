//
//  CashOutViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 27.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public typealias AmountCodePair = (amount: String, code: String)

public class CashOutViewModel {
    
    public let amountViewModel: CashOutAmountViewModel
    
    public let generalViewModel: CashOutGeneralViewModel
    
    public let bankAccountViewModel: CashOutBankAccountViewModel
    
    public let amountObservable: Observable<AmountCodePair>
    
    public let exchangeCourceObservable: Observable<AmountCodePair>
    
    public let totalObservable: Observable<AmountCodePair>
    
    public let trigger = PublishSubject<Void>()
    
    public let errors: Driver<[AnyHashable: Any]>
    
    public let success: Driver<LWModelCashOutSwiftResult>
    
    public let loadingViewModel: LoadingViewModel
    
    private let cashOutService: CashOutService
    
    private let disposeBag = DisposeBag()
    
    public init(
        amountViewModel: CashOutAmountViewModel,
        generalViewModel: CashOutGeneralViewModel,
        bankAccountViewModel: CashOutBankAccountViewModel,
        authManager: LWRxAuthManager,
        currencyExchanger: CurrencyExchanger,
        cashOutService: CashOutService
    ) {
        self.amountViewModel = amountViewModel
        self.generalViewModel = generalViewModel
        self.bankAccountViewModel = bankAccountViewModel
        self.cashOutService = cashOutService
        
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
        
        let cashOutResultObservable = trigger.asObservable()
            .withLatestFrom(walletAndAmountObservable)
            .map { data in
                let (wallet, amount) = data
                return CashOutService.CashOutData(amount: amount,
                                                  asset: wallet.asset,
                                                  bankName: bankAccountViewModel.bankName.value,
                                                  iban: bankAccountViewModel.iban.value,
                                                  bic: bankAccountViewModel.bic.value,
                                                  accountHolder: bankAccountViewModel.accountHolder.value,
                                                  accountHolderAddress: bankAccountViewModel.accountHolderAddress.value,
                                                  reason: generalViewModel.transactionReason.value,
                                                  notes: generalViewModel.additionalNotes.value)
            }
            .flatMapLatest { cashOutService.swiftCashOut(withData: $0) }
            .shareReplay(1)
        
        success = cashOutResultObservable
            .filterSuccess()
            .asDriver(onErrorJustReturn: LWModelCashOutSwiftResult.empty)
        
        errors = cashOutResultObservable
            .filterError()
            .asDriver(onErrorJustReturn: [:])
        
        loadingViewModel = LoadingViewModel([cashOutResultObservable.isLoading()])
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

extension PublishSubject where Element == Void {
    
    public func toggle() {
        self.onNext(Void())
    }
    
}
