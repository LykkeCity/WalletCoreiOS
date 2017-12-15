//
//  SignUpStep.swift
//  ModernMoney
//
//  Created by Georgi Stanev on 13.12.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import WalletCore
import RxSwift

enum SignUpStep: Int {
    case email = 1
    case confirmEmailWithCode = 2
    case setPassword = 3
    case setPasswordHint = 4
    case fillProfile = 5
    case setPhone = 6
    case confirmPhone = 7
    case setPin = 8
    case generateWallet = 9
}

// MARK: - Singleton
extension SignUpStep {
    static var instance: SignUpStep? {
        get {
            return UserDefaults.standard.getSignUpStep()
        }
        
        set {
            guard let signUpStep = newValue else {
                return
            }
            
            UserDefaults.standard.set(signUpStep: signUpStep)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func resetInstance() {
        UserDefaults.standard.nulifySignUpStep()
    }
}

// MARK: - Mappers
extension SignUpStep {
    
    typealias ControllerResult = (formController: FormController?, viewController: UIViewController?, showPin: Bool)
    
    func initializeFormController(
        authManager: LWRxAuthManager = LWRxAuthManager.instance,
        keychainManager: LWKeychainManager = LWKeychainManager.instance()
    ) -> Observable<ApiResult<ControllerResult?>> {
        
        return authManager.settings.request()
            .map{personalData -> ApiResult<ControllerResult?> in
            
                switch personalData {
                case .loading:
                    return .loading
                    
                case .success(let data):
                    return .success(withData: self.initializeFormController(personlData: data, keychainManager: keychainManager))
            
                case .error(let errorData):
                    return .error(withData: errorData)
                    
                case .notAuthorized:
                    return .success(withData: self.initializeFormController(personlData: nil, keychainManager: keychainManager))
                    
                case .forbidden:
                    return .forbidden
                }
            }
            .shareReplay(1)
    }
        
    func initializeFormController(personlData: LWPacketPersonalData?, keychainManager: LWKeychainManager) -> ControllerResult {
        let email = getEmail(fromPacket: personlData)
        let phone = getPhone(fromPacket: personlData)
        
        switch self {
        
        case .email:
            return (formController: SignUpEmailFormController(email: email), viewController: nil, showPin: false)
            
        case .confirmEmailWithCode:
            return (formController: SignUpEmailCodeFormController(email: email), viewController: nil, showPin: false)
            
        case .setPassword:
            return (formController: SignUpSetPasswordFormController(email: email), viewController: nil, showPin: false)
            
        case .setPasswordHint:
            return (formController: SignUpSetPasswordFormController(email: email), viewController: nil, showPin: false)
            
        case .fillProfile:
            return (formController: SignUpFillProfileFormController(), viewController: nil, showPin: false)
            
        case .setPhone:
            return (formController: SignUpFillPhoneFormController(), viewController: nil, showPin: false)
            
        case .confirmPhone:
            guard let phone = phone else {
                return (formController: SignUpFillPhoneFormController(), viewController: nil, showPin: false)
            }
            
            return (formController: SignInConfirmPhoneFormController(signIn: false, phone: phone), viewController: nil, showPin: false)
            
        case .setPin:
            return (formController: SignInConfirmPhoneFormController(signIn: false, phone: phone ?? ""), viewController: nil, showPin: true)
            
        case .generateWallet:
            let shakeViewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "signUpShake")
            return (formController: nil, viewController: shakeViewController, showPin: false)
        }
    }
    
    static func initFrom(formController: FormController?) -> SignUpStep? {
        
        guard let formController = formController else {
            return nil
        }
        
        if formController is SignUpEmailFormController {
            return SignUpStep.email
        }
        
        if formController is SignUpEmailCodeFormController {
            return SignUpStep.confirmEmailWithCode
        }
        
        if formController is SignUpSetPasswordFormController {
            return SignUpStep.setPassword
        }
        
        if formController is SignUpPasswordHintFormController {
            return SignUpStep.setPasswordHint
        }
        
        if formController is SignUpFillProfileFormController {
            return SignUpStep.fillProfile
        }
        
        if formController is SignUpFillPhoneFormController {
            return SignUpStep.setPhone
        }
        
        if formController is SignInConfirmPhoneFormController {
            return SignUpStep.confirmPhone
        }
        
        return nil
    }
}

// MARK: - Utilities
fileprivate extension SignUpStep {
    func getPhone(fromPacket packet:  LWPacketPersonalData?) -> String? {
        guard let phone = packet?.data?.phone, phone.isNotEmpty else {
            return UserDefaults.standard.getTempPhone()
        }
        
        return phone
    }
    
    func getEmail(fromPacket packet: LWPacketPersonalData?) -> String {
        return packet?.data?.email ?? UserDefaults.standard.getTempEmail() ?? ""
    }
}

// MARK: - RX
extension ObservableType where Self.E == ApiResult<SignUpStep.ControllerResult?> {
    func filterSuccess() -> Observable<SignUpStep.ControllerResult?> {
        return filter{ $0.isSuccess }.map{
            guard let controller = $0.getSuccess() else {
                return nil
            }
            
            return controller
        }
    }
    
    func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
