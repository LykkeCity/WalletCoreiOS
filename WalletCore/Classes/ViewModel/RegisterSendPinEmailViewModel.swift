//
//  RegisterSendPinEmailViewModel.swift
//  Pods
//
//  Created by Bozidar Nikolic on 8/30/17.
//
//

import Foundation
import RxSwift
import RxCocoa

open class RegisterSendPinEmailViewModel {
    public let pin = Variable<String>("")
    public let email = Variable<String>("")
    let fake = Variable<String>("")
    public let loading: Observable<Bool>
    public let resultConfirmPin: Driver<ApiResult<LWPacketEmailVerificationGet>>
    public let resultResendPin: Driver<ApiResult<LWPacketEmailVerificationSet>>
    
    public init(submitConfirmPin: Observable<Void>, submitResendPin: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        resultConfirmPin = submitConfirmPin
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(pin: pin, email: email, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        
        
        resultResendPin = submitResendPin
            .throttle(1, scheduler: MainScheduler.instance)
            .mapResendPin(email: email, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        let m = Observable.merge([self.resultConfirmPin.asObservable().isLoading(), self.resultResendPin.asObservable().isLoading()])
        loading = m
    }
    
    
    public var isValid : Observable<Bool>{
        return Observable.combineLatest(self.fake.asObservable(), self.pin.asObservable()  , resultSelector:
            {(fake,pin1) -> Bool in
                return pin1.characters.count > 3
        })
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        pin: Variable<String>,
        email: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketEmailVerificationGet>> {
        
        return flatMapLatest{authData in
            authManager.pinvalidation.validatePinCode(withData: email.value, pin: pin.value)
            }
            .shareReplay(1)
    }
    
    func mapResendPin(
        email: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketEmailVerificationSet>> {
        
        return flatMapLatest{authData in
            authManager.emailverification.verifyEmail(withData: email.value)
            }
            .shareReplay(1)
    }
}


