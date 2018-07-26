//
//  SignUpPinSetViewModel.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 9/12/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class SignUpPinSetViewModel {

    public let pin = Variable<String>("")
    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketPinSecuritySet>>
    let fake = Variable<String>("")

    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(pin: pin, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))

        loading = self.result.asObservable().isLoading()

    }

    public var isValid: Observable<Bool> {
        return Observable.combineLatest(self.pin.asObservable(), self.fake.asObservable(), resultSelector: {(pin, _) -> Bool in
                return pin.characters.count > 3

        })
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        pin: Variable<String>,
        authManager: LWRxAuthManager
    ) -> Observable<ApiResult<LWPacketPinSecuritySet>> {

        return flatMapLatest {_ in
            authManager.pinset.request(withParams: pin.value)
        }
        .shareReplay(1)
    }
}
