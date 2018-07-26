//
//  TransactionViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

open class TransactionViewModel {
    typealias that = TransactionViewModel

    /// Transaction due date.Example: "July 21, 2017"
    public let date: Driver<String>

    /// Amount in base asset.Example: "(+12,123.00 AUD)"
    public let amountInBase: Driver<String>

    /// Amount in transaction asset.Example: "+123.54 EUR"
    public let amount: Driver<String>

    /// Title of transaction.Example: "Receive Lykke Shares"
    public let title: Driver<String>

    /// Icon of transaction according transaction type
    public let icon: Driver<UIImage>

    public let transaction: LWBaseHistoryItemType

    public init(item: LWBaseHistoryItemType, dependency: TransactionsViewModel.Dependency) {

        let assetObservable = dependency.authManager.allAssets.request(byId: item.asset).filterSuccess()
        let volume = (item.volume ?? 0).decimalValue
        let itemObservable = Observable.just(item)
        let volumeObservable = Observable.just(Optional(volume))

        self.transaction = item

        self.date = itemObservable
            .mapToDate(withFormatter: dependency.formatter)
            .asDriver(onErrorJustReturn: "")

        self.amountInBase = assetObservable
            .mapToAmountInBase(volume: volume, currencyExcancher: dependency.currencyExcancher, formatter: dependency.formatter)
            .asDriver(onErrorJustReturn: "")

        self.amount = Observable.combineLatest(volumeObservable, assetObservable)
            .map { dependency.formatter.formatAmount(volume: $0.0, asset: $0.1) }
            .asDriver(onErrorJustReturn: "")

        self.title = Observable.combineLatest(assetObservable, itemObservable) {(asset: $0, item: $1)}
            .map { dependency.formatter.formatTransactionTitle(asset: $0.asset, item: $0.item) }
            .asDriver(onErrorJustReturn: "")

        self.icon = itemObservable
            .mapToIcon()
            .asDriver(onErrorJustReturn: UIImage())
    }
}

fileprivate extension ObservableType where Self.E == LWBaseHistoryItemType {
    func mapToDate(withFormatter formatter: TransactionFormatterProtocol) -> Observable<String> {
        return
            map {$0.dateTime}
            .filterNil()
            .map { formatter.format(date: $0) }
            .startWith("")
    }

    func mapToIcon() -> Observable<UIImage> {
        return map {$0.asImage()}.filterNil()
    }
}

fileprivate extension ObservableType where Self.E == LWAssetModel? {
    func mapToAmountInBase(volume: Decimal, currencyExcancher: CurrencyExchanger, formatter: TransactionFormatterProtocol) -> Observable<String> {
        return flatMap {baseAsset -> Observable<(baseAsset: LWAssetModel, amount: Decimal)?> in
            guard let baseAsset = baseAsset else {return Observable.just(nil)}
            return currencyExcancher.exchangeToBaseAsset(amount: volume, from: baseAsset, bid: false)
        }
        .map { formatter.formatAmount(volume: $0?.amount, asset: $0?.baseAsset) }
        .map {"(\($0))"}
        .startWith(Localize("newDesign.calculating"))
    }
}
