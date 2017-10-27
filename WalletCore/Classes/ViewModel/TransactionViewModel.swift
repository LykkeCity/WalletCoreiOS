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
    
    /// Amaunt in base asset.Example: "(+12,123.00 AUD)"
    public let amauntInBase: Driver<String>
    
    /// Amaun in transaction asset.Example: "+123.54 EUR"
    public let amaunt: Driver<String>
    
    /// Title of transaction.Example: "Receive Lykke Shares"
    public let title: Driver<String>
    
    /// Icon of transaction according transaction type
    public let icon: Driver<UIImage>
    
    public init(item: LWBaseHistoryItemType, currencyExcancher: CurrencyExchanger, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        let assetObservable = authManager.allAssets.requestAsset(byId: item.asset).filterSuccess()
        let volume = (item.volume ?? 0).decimalValue
        let itemObservable = Observable.just(item)
        let volumeObservable = Observable.just(Optional(volume))
        
        self.date = itemObservable
            .mapToDate()
            .asDriver(onErrorJustReturn: "")
        
        self.amauntInBase = assetObservable
            .mapToAmountInBase(volume: volume, currencyExcancher: currencyExcancher)
            .asDriver(onErrorJustReturn: "")

        self.amaunt = Observable.combineLatest(volumeObservable, assetObservable){(volume: $0, asset: $1)}
            .mapToAmount()
            .asDriver(onErrorJustReturn: "")
        
        self.title = Observable.combineLatest(assetObservable, itemObservable){(asset: $0, item: $1)}
            .mapToDisplayName()
            .asDriver(onErrorJustReturn: "")
        
        self.icon = itemObservable
            .mapToIcon()
            .asDriver(onErrorJustReturn: UIImage())
    }
}

fileprivate extension ObservableType where Self.E == LWBaseHistoryItemType {
    func mapToDate() -> Observable<String> {
        return
            map{$0.dateTime}
            .filterNil()
            .map{DateFormatter.mediumStyle.string(from: $0)}
            .startWith("")
    }
    
    func mapToIcon() -> Observable<UIImage> {
        return
            map{$0.asImage()}
            .filterNil()
    }
}

fileprivate extension ObservableType where Self.E == LWAssetModel? {
    func mapToAmountInBase(volume: Decimal, currencyExcancher: CurrencyExchanger) -> Observable<String> {
        return flatMap{baseAsset -> Observable<(baseAsset: LWAssetModel, amaunt: Decimal)?> in
            guard let baseAsset = baseAsset else {return Observable.just(nil)}
            return currencyExcancher.exchangeToBaseAsset(amaunt: volume, from: baseAsset, bid: false)
        }
        .map{(volume: $0?.amaunt, asset: $0?.baseAsset)}
        .mapToAmount()
        .map{"(\($0))"}
        .startWith(Localize("newDesign.calculating"))
    }
}

fileprivate extension ObservableType where Self.E == (asset: LWAssetModel?, item: LWBaseHistoryItemType) {
    func mapToDisplayName() -> Observable<String> {
        return map{data in
            let assetName = data.asset?.displayFullName ?? ""
            return "\(data.item.localizedString) \(assetName)"
        }
    }
}

fileprivate extension ObservableType where Self.E == (volume: Decimal?, asset: LWAssetModel?) {
    func mapToAmount() -> Observable<String> {
        return map{data -> String in
            guard let volume = data.volume else {return Localize("newDesign.notAvailable")}
            
            let volumeString = volume.convertAsCurrency(
                code: data.asset?.name ?? "",
                symbol: "",
                accuracy: Int(data.asset?.accuracy ?? 2)
            )
            
            return volume > 0 ? "+\(volumeString)" : "\(volumeString)"
        }
    }
}
