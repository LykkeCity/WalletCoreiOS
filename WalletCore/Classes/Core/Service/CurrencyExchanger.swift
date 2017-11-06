//
//  CurrencyConverter.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/21/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class CurrencyExchanger {
    public let authManager: LWRxAuthManager
    public let pairRates: Variable<[LWAssetPairRateModel]> = Variable([])
    private let disposeBag = DisposeBag()
    
    public init(refresh: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        self.authManager = authManager
        
        refresh
            .flatMap{_ in authManager.assetPairRates.requestAssetPairRates(ignoreBase: true).filterSuccess()}
            .bind(to: pairRates)
            .disposed(by: disposeBag)
    }
    
    /// Convert an asset's amaunt into a value of another asset
    ///
    /// - Parameters:
    ///   - amaunt: Amaunt you want to exchange
    ///   - from: Asset you have and want to exchange
    ///   - to: Asset you want to be exchanged for
    ///   - bid: Bid or ask price
    /// - Returns: Observable of exchanged amaunt that will updates each 5 seconds according pair rates
    func exchange(amaunt: Decimal, from: LWAssetModel, to: LWAssetModel, bid: Bool) -> Observable<Decimal?> {
        let pair = from.getPairId(withAsset: to)
        
        //If from/to are the same currency then return the same amaunt
        if pair == from.getPairId(withAsset: from) {
            return Observable.just(amaunt)
        }
        
        let reversedPair = to.getPairId(withAsset: from)
        
        return pairRates.asObservable()
            .map{rates -> (pairModel: LWAssetPairRateModel?, reversed: Bool) in
                guard let pairModel = rates.find(byPair: pair) else {
                    return (pairModel: rates.find(byPair: reversedPair), reversed: true)
                }
                
                return (pairModel: pairModel, reversed: false)
            }
            .map{
                guard let rate = (bid ? $0.pairModel?.bid : $0.pairModel?.ask)?.decimalValue else { return nil }
                if !$0.reversed { return amaunt * rate}
                
                guard let reversedRate = (bid ? $0.pairModel?.ask : $0.pairModel?.bid)?.decimalValue else { return nil }
                if reversedRate == 0.0 {return 0.0} //make sure to not divide by zero
                return amaunt / reversedRate //if the pair is reversed divide by rate instead of multiply
            }
            .shareReplay(1)
    }
    
    /// Convert an asset's amaunt into user's base asset
    ///
    /// - Parameters:
    ///   - amaunt: Amaunt you want to exchange
    ///   - from: Asset you have and want to exchange
    ///   - bid: Bid or ask price
    /// - Returns: Observable of exchanged amaunt that will updates each 5 seconds according pair rates
    func exchangeToBaseAsset(amaunt: Decimal, from: LWAssetModel, bid: Bool) -> Observable<(baseAsset: LWAssetModel, amaunt: Decimal)?> {
        return authManager.baseAsset.request().filterSuccess()
            .flatMap{[weak self] baseAsset -> Observable<(baseAsset: LWAssetModel, amaunt: Decimal)?> in
                guard let this = self else {return Observable.just(nil)}
                return this
                    .exchange(amaunt: amaunt, from: from, to: baseAsset, bid: bid)
                    .map{
                        guard let amaunt = $0 else {return nil}
                        return (baseAsset: baseAsset, amaunt: amaunt)
                    }
            }
            .shareReplay(1)
    }
}
