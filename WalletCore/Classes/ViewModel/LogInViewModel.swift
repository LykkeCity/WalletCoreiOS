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
    
    public enum NeedToFill {
        case phone
        case pin
        case fullName
    }
    
    public let email = Variable<String>("")
    public let password = Variable<String>("")
    public let clientInfo = Variable<String>("")
    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketAuthentication>>
    public let showPinViewController: Driver<Void>
    public let needToFill: Driver<NeedToFill>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(email: email, password: password, clientInfo: clientInfo, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        showPinViewController = result.showPin()
        needToFill = result.needToFill()
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

fileprivate extension SharedSequenceConvertibleType
    where SharingStrategy == DriverSharingStrategy, E == ApiResult<LWPacketAuthentication> {
    
    func showPin() -> Driver<Void> {
        return asObservable()
            .filterSuccess()
            .filter{ !$0.isPhoneEmpty }
            .filter{ $0.isPinEntered }
            .map{ _ in () }
            .asDriver(onErrorJustReturn: ())
    }
    
    func needToFill() -> Driver<LogInViewModel.NeedToFill> {
        return asObservable()
            .filterSuccess()
            .debug("joro: before")
            .map{ $0.needToFill }
            .debug("joro: after")
            .asDriver(onErrorJustReturn: nil)
            .filterNil()
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

public extension LogInViewModel.NeedToFill {
    func isPhone() -> Bool {
        guard case .phone = self else { return false }
        return true
    }
    
    func isPin() -> Bool {
        guard case .pin = self else { return false }
        return true
    }
    
    func isFullName() -> Bool {
        guard case .fullName = self else { return false }
        return true
    }
}

fileprivate extension LWPacketAuthentication {
    var isPhoneEmpty: Bool {
        guard let phone = personalData?.phone else {
            return true
        }
        
        return phone.isEmpty
    }
    
    var isFullNameEmpty: Bool {
        guard let firstName = personalData?.firstName, let lastName = personalData?.lastName else {
            return true
        }
        
        return firstName.isEmpty || lastName.isEmpty
    }
    
    var needToFill: LogInViewModel.NeedToFill? {
        if isFullNameEmpty {
            return .fullName
        }
        
        if isPhoneEmpty {
            return .phone
        }
        
        if !isPinEntered {
            return .pin
        }
        
        return nil
    }
}
