//
//  LogInViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/17/17.
//
//

import Foundation
import RxSwift
import RxCocoa


open class LogInViewModel {
    
    public let email = Variable<String>("")
    public let password = Variable<String>("")
    public let clientInfo = Variable<String>("")
    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketAuthentication>>
    
    public init(submit: Observable<Void>, forgotPassword: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(email: email, password: password, clientInfo: clientInfo, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loading = result.asObservable().isLoading()
    }
    
    public var isValid : Observable<Bool>{
        return Observable.combineLatest( self.email.asObservable() , self.password.asObservable(), resultSelector:
            {(email, password) -> Bool in
                return email.characters.count > 0
                    && password.characters.count > 0 && LWValidator.validateEmail(self.email.value)
        })
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        email: Variable<String>,
        password: Variable<String>,
        clientInfo: Variable<String>,
        authManager: LWRxAuthManager
    ) -> Observable<ApiResult<LWPacketAuthentication>> {
        
        return map{_ -> LWAuthenticationData in
            let authData = LWAuthenticationData()
            authData.email = email.value
            authData.password = password.value
            authData.clientInfo = clientInfo.value
            
            return authData
        }
        .flatMapLatest{authData in
            authManager.auth.request(withParams: authData)
        }
        .shareReplay(1)
    }
}
