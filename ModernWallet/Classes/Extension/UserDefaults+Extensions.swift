//
//  UserDefaults+Extensions.swift
//  ModernMoney
//
//  Created by Georgi Stanev on 13.12.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    private static let keys = (
        tempEmail: "tempEmail",
        tempPhone: "tempPhone",
        signUpStep: "SignUpStep",
        loggedIn: "loggedIn"
    )
    
    func set(tempEmail: String) {
        set(tempEmail, forKey: UserDefaults.keys.tempEmail)
    }
    
    func getTempEmail() -> String? {
        return string(forKey: UserDefaults.keys.tempEmail)
    }

    func set(tempPhone: String) {
        set(tempPhone, forKey: UserDefaults.keys.tempPhone)
    }
    
    func getTempPhone() -> String? {
        return string(forKey: UserDefaults.keys.tempPhone)
    }
    
    func getSignUpStep() -> SignUpStep? {
        return SignUpStep(rawValue: integer(forKey: UserDefaults.keys.signUpStep))
    }
    
    func nulifySignUpStep() {
        set(nil, forKey: UserDefaults.keys.signUpStep)
        synchronize()
    }
    
    func set(signUpStep: SignUpStep) {
        set(signUpStep.rawValue, forKey: UserDefaults.keys.signUpStep)
    }
    
    func set(loggedIn: Bool) {
        set(loggedIn, forKey: UserDefaults.keys.loggedIn)
    }
    
    var isLoggedIn: Bool {
        return bool(forKey: UserDefaults.keys.loggedIn)
    }
    
    var isNotLoggedIn: Bool {
        return !isLoggedIn
    }
}
