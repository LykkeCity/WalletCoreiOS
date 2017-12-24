//
//  SignUpRegistrationViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/22/17.
//
//

import Foundation
import RxSwift
import RxCocoa

open class SignUpRegistrationViewModel {
    public let email = Variable<String>("")
    public let password = Variable<String>("")
    public let reenterPassword = Variable<String>("")
    public let clientInfo = Variable<String>("")
    public let hint = Variable<String>("")
    let fake = Variable<String>("")
    
    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketRegistration>>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(email: email, password: password, clientInfo: clientInfo, hint: hint, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loading = result.asObservable().isLoading().shareReplay(1)
    }
    
    public lazy var isValid : Observable<Bool> = {
        return Observable.combineLatest( self.password.asObservable(), self.reenterPassword.asObservable(), resultSelector:
            {(password, reenterpass) -> Bool in
                return password.characters.count > 5
                    && reenterpass.characters.count > 5 && self.password.value == self.reenterPassword.value
        })
    }()
    
    public lazy var isValidHint : Observable<Bool> = {
        return Observable.combineLatest( self.hint.asObservable(), self.fake.asObservable(), resultSelector:
            {(hint, fake) -> Bool in
                return hint.characters.count > 2
        })
    }()
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        email: Variable<String>,
        password: Variable<String>,
        clientInfo: Variable<String>,
        hint: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketRegistration>> {
        
        return map{_ -> LWRegistrationData in
            let authData = LWRegistrationData()
            authData.email = email.value
            authData.password = password.value
            authData.clientInfo = clientInfo.value
            authData.passwordHint = hint.value
            
            return authData
            }
            .flatMapLatest{authData in
                authManager.registration.request(withParams: authData)
            }
            .shareReplay(1)
    }
}
