//
//  CurrencyConverter.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/21/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public protocol CurrencyExchangerProtocol {
    /// Convert an asset's amount into a value of another asset
    ///
    /// - Parameters:
    ///   - amount: Amount you want to exchange
    ///   - from: Asset you have and want to exchange
    ///   - to: Asset you want to be exchanged for
    ///   - bid: Bid or ask price
    /// - Returns: Observable of exchanged amount that will updates each 5 seconds according pair rates
    func exchange(amount: Decimal, from: LWAssetModel, to: LWAssetModel, bid: Bool) -> Observable<Decimal?>

    /// Convert an asset's amount into user's base asset
    ///
    /// - Parameters:
    ///   - amount: Amount you want to exchange
    ///   - from: Asset you have and want to exchange
    ///   - bid: Bid or ask price
    /// - Returns: Observable of exchanged amount that will updates each 5 seconds according pair rates
    func exchangeToBaseAsset(amount: Decimal, from: LWAssetModel, bid: Bool) -> Observable<(baseAsset: LWAssetModel, amount: Decimal)?>
}

public class CurrencyExchanger: CurrencyExchangerProtocol {
    public let authManager: LWRxAuthManagerProtocol
    public let pairRates: Variable<[LWAssetPairRateModel]> = Variable([])
    private let disposeBag = DisposeBag()

    public init(refresh: Observable<Void>, authManager: LWRxAuthManagerProtocol = LWRxAuthManager.instance) {

        self.authManager = authManager

        refresh
            .flatMap {_ in authManager.assetPairs.request().filterSuccess()}
            .flatMap {_ in authManager.assetPairRates.request(withParams: true).filterSuccess()}
            .bind(to: pairRates)
            .disposed(by: disposeBag)

    }

    /// Convert an asset's amount into a value of another asset
    ///
    /// - Parameters:
    ///   - amount: Amount you want to exchange
    ///   - from: Asset you have and want to exchange
    ///   - to: Asset you want to be exchanged for
    ///   - bid: Bid or ask price
    /// - Returns: Observable of exchanged amount that will updates each 5 seconds according pair rates
    public func exchange(amount: Decimal, from: LWAssetModel, to: LWAssetModel, bid: Bool) -> Observable<Decimal?> {
        if (from == to) {
            return Observable.just(amount)
        }

        let pairObserver =  authManager.assetPairs
            .request(baseAsset: from, quotingAsset: to)
            .filterSuccess()

        return Observable.combineLatest(pairRates.asObservable(), pairObserver)
            .map { rates, pair in
                return (pairModel: rates.find(byPair: pair?.identity ?? ""), reversed: pair?.quotingAsset == from)
            }
            .map {
                guard let rate = (bid ? $0.pairModel?.bid : $0.pairModel?.ask)?.decimalValue else { return nil }
                if !$0.reversed { return amount * rate}

                guard let reversedRate = (bid ? $0.pairModel?.ask : $0.pairModel?.bid)?.decimalValue else { return nil }
                if reversedRate == 0.0 {return 0.0} //make sure to not divide by zero
                return amount / reversedRate //if the pair is reversed divide by rate instead of multiply
            }
            .shareReplay(1)
    }

    /// Convert an asset's amount into user's base asset
    ///
    /// - Parameters:
    ///   - amount: Amount you want to exchange
    ///   - from: Asset you have and want to exchange
    ///   - bid: Bid or ask price
    /// - Returns: Observable of exchanged amount that will updates each 5 seconds according pair rates
    public func exchangeToBaseAsset(amount: Decimal, from: LWAssetModel, bid: Bool) -> Observable<(baseAsset: LWAssetModel, amount: Decimal)?> {
        return authManager.baseAsset.request().filterSuccess()
            .flatMap {[weak self] baseAsset -> Observable<(baseAsset: LWAssetModel, amount: Decimal)?> in
                guard let this = self else {return Observable.just(nil)}
                return this
                    .exchange(amount: amount, from: from, to: baseAsset, bid: bid)
                    .map {
                        guard let amount = $0 else {return nil}
                        return (baseAsset: baseAsset, amount: amount)
                    }
            }
            .shareReplay(1)
    }
}
