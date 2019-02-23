//
//  SignUpEmailViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/18/17.
//
//

import Foundation
import RxSwift
import RxCocoa

open class SignUpEmailViewModel {
    public let email = Variable<String>("")
    let fake = Variable<String>("")
    public let loading: Observable<Bool>
    public let result: Observable<ApiResult<LWPacketEmailVerificationSet>>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(email: email, authManager: authManager)
        
        loading = result.asObservable().isLoading()
    }
    public var isValid : Observable<Bool>{
        return Observable.combineLatest(self.fake.asObservable(), self.email.asObservable(), resultSelector:
            {(fake, email) -> Bool in
                return email.characters.count > 0 && LWValidator.validateEmail(self.email.value)
        })
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        email: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketEmailVerificationSet>> {
        
        return flatMapLatest{authData in
                authManager.emailverification.request(withParams: email.value)
            }
            .share()
    }
}
