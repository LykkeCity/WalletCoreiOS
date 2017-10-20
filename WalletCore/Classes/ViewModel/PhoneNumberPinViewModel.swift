//
//  PhoneNumberPinViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//

import Foundation
import RxSwift
import RxCocoa


open class PhoneNumberPinViewModel{
    public let pin1 = Variable<String>("")
    public let pin2 = Variable<String>("")
    public let pin3 = Variable<String>("")
    public let pin4 = Variable<String>("")
    public let phone = Variable<String>("")
    public let loading: Observable<Bool>
    public let resultConfirmPin: Driver<ApiResult<LWPacketPhoneVerificationGet>>
    public let resultResendPin: Driver<ApiResult<LWPacketPhoneVerificationSet>>
    
    public init(submitConfirmPin: Observable<Void>, submitResendPin: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        resultConfirmPin = submitConfirmPin
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(pin1: pin1, pin2: pin2, pin3: pin3, pin4:pin4, phone: phone, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        
        
        resultResendPin = submitResendPin
            .throttle(1, scheduler: MainScheduler.instance)
            .mapResendPin(phone: phone, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        let m = Observable.merge([self.resultConfirmPin.asObservable().isLoading(), self.resultResendPin.asObservable().isLoading()])
        loading = m
    }
    
    
    public var isValid : Observable<Bool>{
        return Observable.combineLatest( self.pin1.asObservable() , self.pin2.asObservable() , self.pin3.asObservable() ,self.pin4.asObservable() , resultSelector:
            {(pin1, pin2,pin3,pin4) -> Bool in
                return pin1.characters.count > 0
                    && pin2.characters.count > 0
                    && pin3.characters.count > 0
                    && pin4.characters.count > 0
        })
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        pin1: Variable<String>,
        pin2: Variable<String>,
        pin3: Variable<String>,
        pin4: Variable<String>,
        phone: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketPhoneVerificationGet>> {
        
        return flatMapLatest{authData in
            authManager.setPhoneNumberPin.validatePinCode(withData: phone.value, pin: pin1.value+pin2.value+pin3.value+pin4.value)
            }
            .shareReplay(1)
    }
    
    func mapResendPin(
        phone: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketPhoneVerificationSet>> {
        
        return flatMapLatest{authData in
            authManager.setPhoneNumber.setPhoneNumber(withPhone: phone.value)
            }
            .shareReplay(1)
    }
}
