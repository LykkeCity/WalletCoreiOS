//
//  SignUpPhoneConfirmPinViewModel.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 9/8/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class SignUpPhoneConfirmPinViewModel {
    
    public let pin = Variable<String>("")
    public let phone = Variable<String>("")
    let fake = Variable<String>("")
    
    public let loading: Observable<Bool>
    public let resultConfirmPin: Driver<ApiResult<LWPacketPhoneVerificationGet>>
    public let resultResendPin: Driver<ApiResult<LWPacketPhoneVerificationSet>>
    
    public init(submitConfirmPin: Observable<Void>, submitResendPin: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        resultConfirmPin = submitConfirmPin
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(pin: pin, phone: phone, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        
        
        resultResendPin = submitResendPin
            .throttle(1, scheduler: MainScheduler.instance)
            .mapResendPin(phone: phone, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        let m = Observable.merge([self.resultConfirmPin.asObservable().isLoading(), self.resultResendPin.asObservable().isLoading()])
        loading = m
    }
    
    
    public var isValid : Observable<Bool>{
        return Observable.combineLatest( self.pin.asObservable() , self.fake.asObservable(), resultSelector:
            {(pin, fake) -> Bool in
                return pin.characters.count > 3

        })
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        pin: Variable<String>,
        phone: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketPhoneVerificationGet>> {
        
        return flatMapLatest{authData in
            authManager.setPhoneNumberPin.request(withParams: (
                phone: phone.value,
                pin: pin.value
            ))
        }
        .shareReplay(1)
    }
    
    func mapResendPin(
        phone: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketPhoneVerificationSet>> {
        
        return flatMapLatest{authData in
            authManager.setPhoneNumber.request(withParams: phone.value)
        }
        .shareReplay(1)
    }
}
