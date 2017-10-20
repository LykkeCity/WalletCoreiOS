//
//  AssetViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 6/8/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

open class AssetCellViewModel {
    private let asset: Variable<Asset>
    
    public var name: Driver<String>
    public var cryptoValue: Driver<String>
    public var realValue: Driver<String>
    public var percent: Driver<String>
    public var imgURL: Driver<URL?>
    
    public init(_ asset: Variable<Asset>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        self.asset = asset
        
        self.name = asset.asObservable()
            .mapToCryptoName()
            .asDriver(onErrorJustReturn: "")
        
        self.cryptoValue = asset.asObservable()
            .mapToCryptoName()
            .asDriver(onErrorJustReturn: "")
        
        self.realValue = asset.asObservable()
            .mapToRealValue()
            .asDriver(onErrorJustReturn: "")
        
        self.percent = asset.asObservable()
            .mapToPercent()
            .asDriver(onErrorJustReturn: "")
        
        self.imgURL = asset.asObservable()
            .mapToUrl(authManager: authManager)
            .asDriver(onErrorJustReturn: nil)
    }
}

public extension ObservableType where Self.E == Asset {
    func mapToCryptoName() -> Observable<String> {
        return map{$0.cryptoCurrency.name}
    }
    
    func mapToCryptoValue() -> Observable<String> {
        return map{$0.cryptoCurrency.value.convertAsCurrency(
            code: $0.cryptoCurrency.shortName,
            symbol: "",
            accuracy: $0.cryptoCurrency.accuracy
        )}
    }
    
    func mapToRealValue() -> Observable<String> {
        return map{$0.realCurrency}
            .map{$0.value.convertAsCurrency(
                code: $0.shortName,
                symbol: $0.sign ?? "",
                accuracy: $0.accuracy
            )}
            .map{"(\($0))"}
    }
    
    func mapToPercent() -> Observable<String> {
        return map{$0.percent as NSNumber}
            .map{NumberFormatter.percentInstance.string(from: $0) ?? ""}
    }
    
    func mapToUrl(authManager: LWRxAuthManager) -> Observable<URL?> {
        return flatMapLatest{asset in
            return authManager.allAssets
                .requestAsset(byId: asset.cryptoCurrency.identity)
                .filterSuccess()
                .filterNil()
                .map{$0.iconUrl}
        }
    }
}

public extension Decimal {
    public func convertAsCurrency(assetPairModel: LWAssetPairModel) -> String {
        return convertAsCurrency(code: "", symbol: "", accuracy: assetPairModel.accuracy.intValue)
    }
    
    public func convertAsCurrency(code: String, symbol: String, accuracy: Int) -> String {
        let formatterNumber = NumberFormatter
            .currencyInstance(accuracy: accuracy)
            .string(from: self as NSNumber) ?? ""
        
        return "\(symbol)\(formatterNumber) \(code)"
    }
    
    public func convertAsCurrency(asset: LWAssetModel?, withCode: Bool) -> String {
        return convertAsCurrency(
            code: withCode ? (asset?.name ?? "") : "",
            symbol: asset?.symbol ?? "",
            accuracy: Int(asset?.accuracy ?? 0)
        )
    }

    public func convertAsCurrency(asset: LWAssetModel?) -> String {
        return convertAsCurrency(
            code: asset?.name ?? "",
            symbol: asset?.symbol ?? "",
            accuracy: Int(asset?.accuracy ?? 0)
        )
    }
    
    public func convertAsCurrencyWithSymbol(asset: LWAssetModel?) -> String {
        return convertAsCurrency(
            code: "",
            symbol: asset?.symbol ?? asset?.name ?? "",
            accuracy: Int(asset?.accuracy ?? 0)
        )
    }
    
    public func convertAsCurrency(currecy: Asset.Currency) -> String {
        return convertAsCurrency(
            code: "",
            symbol: currecy.sign ?? "",
            accuracy: Int(currecy.accuracy)
        )
    }
    
    public func convertAsCurrencyStrip(asset: LWAssetModel?) -> String {
        return convertAsCurrency(
            code: "",
            symbol: "",
            accuracy: Int(asset?.accuracy ?? 0)
        )
    }
}
