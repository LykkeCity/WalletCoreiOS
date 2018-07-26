//
//  AddMoneyCryptoCurrencyCellViewModel.swift
//  WalletCore
//
//  Created by Ivan Stefanovic on 12/20/17.
//

import Foundation
import RxSwift
import RxCocoa

open class AddMoneyCryptoCurrencyCellViewModel {
    public let name: Driver<String>
    public let address: Driver<String?>
    public var imgUrl: Driver<URL?>

    public init(_ currency: Variable<LWAddMoneyCryptoCurrencyModel>) {
        let currencyObservable = currency.asObservable()

        name = currencyObservable
            .mapToName()
            .asDriver(onErrorJustReturn: "")

        address = currencyObservable
            .mapToAddress()
            .asDriver(onErrorJustReturn: "")

        imgUrl = currencyObservable
            .mapToImage()
            .asDriver(onErrorJustReturn: nil)
    }
}

fileprivate extension ObservableType where Self.E == LWAddMoneyCryptoCurrencyModel {

    func mapToImage() -> Observable<URL?> {
        return map {$0.imgUrl}
    }

    func mapToName() -> Observable<String> {
        return map {$0.name}
    }
    func mapToAddress() -> Observable<String?> {
        return map {$0.address}
    }
}
