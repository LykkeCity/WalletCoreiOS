//
//  AssetCollectionCellViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 13.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

open class AssetCollectionCellViewModel {

    private let asset: Variable<Asset>

    public var name: Driver<String>
    public var cryptoAmount: Driver<String>
    public var cryptoCode: Driver<String>
    public var realAmount: Driver<String>
    public var realCode: Driver<String>
    public var imgURL: Driver<URL?>

    public init(_ asset: Variable<Asset>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        self.asset = asset

        self.name = asset.asObservable()
            .mapToCryptoShortName()
            .asDriver(onErrorJustReturn: "")

        self.cryptoAmount = asset.asObservable()
            .mapToCryptoAmount()
            .asDriver(onErrorJustReturn: "")

        self.cryptoCode = asset.asObservable()
            .mapToCryptoCode()
            .asDriver(onErrorJustReturn: "")

        self.realAmount = asset.asObservable()
            .filter {($0.wallet?.assetPairId != nil)}
            .mapToRealAmount()
            .asDriver(onErrorJustReturn: "")

        self.realCode = asset.asObservable()
            .filter {($0.wallet?.assetPairId != nil)}
            .mapToRealCode()
            .asDriver(onErrorJustReturn: "")

        self.imgURL = asset.asObservable()
            .mapToUrl(authManager: authManager)
            .asDriver(onErrorJustReturn: nil)
    }

}

internal extension ObservableType where Self.E == Asset {

    func mapToCryptoShortName() -> Observable<String> {
        return map {$0.cryptoCurrency.shortName}
    }

    func mapToCryptoAmount() -> Observable<String> {
        return map {$0.cryptoCurrency.value.convertAsCurrency(
            code: "",
            symbol: "",
            accuracy: $0.cryptoCurrency.accuracy
            )}
    }

    func mapToCryptoCode() -> Observable<String> {
        return map { $0.cryptoCurrency.shortName }
    }

    func mapToRealAmount() -> Observable<String> {
        return map {$0.realCurrency}
            .map {$0.value.convertAsCurrency(
                code: "",
                symbol: $0.sign ?? "",
                accuracy: $0.accuracy
                )}
    }

    func mapToRealCode() -> Observable<String> {
        return map { $0.realCurrency.shortName }
    }

}
