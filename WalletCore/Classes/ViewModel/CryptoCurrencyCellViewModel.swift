//
//  AddMoneyCurrencyViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class CryptoCurrencyCellViewModel {
    
    public let name: Driver<String>
    public let capitalization: Driver<String>
    public let percentVariance: Driver<String>
    public let variance: Driver<String>
    public var img: Driver<UIImage>
    
    public init(_ currency: Variable<LWACurrencyMarketValueModel>) {
        let currencyObservable = currency.asObservable()
        
        name = currencyObservable
            .mapToName()
            .asDriver(onErrorJustReturn: "")
        
        capitalization = currencyObservable
            .mapToCapitalization()
            .asDriver(onErrorJustReturn: "")
        
        percentVariance = currencyObservable
            .mapToCapitalization()
            .asDriver(onErrorJustReturn: "")
        
        variance = currencyObservable
            .mapToVariance()
            .asDriver(onErrorJustReturn: "")
        
        img = currencyObservable
            .mapToImage()
            .asDriver(onErrorJustReturn: UIImage())
    }
}

fileprivate extension ObservableType where Self.E == LWACurrencyMarketValueModel {
    func mapToCapitalization() -> Observable<String> {
        return map{$0.capitalization.value.convertAsCurrency(
            code: $0.capitalization.shortName,
            symbol: $0.capitalization.sign ?? "",
            accuracy: $0.capitalization.accuracy)
        }
    }
    
    func mapToPercent() -> Observable<String> {
        return map{"\($0.variance.percent) %"}
    }
    
    func mapToVariance() -> Observable<String> {
        return map{$0.variance.currency.value.convertAsCurrency(
            code: $0.variance.currency.shortName,
            symbol: $0.variance.currency.sign ?? "",
            accuracy: $0.variance.currency.accuracy
        )}
    }
    
    func mapToImage() -> Observable<UIImage> {
        return map{$0.img}
    }
    
    func mapToName() -> Observable<String> {
        return map{$0.name}
    }
}
