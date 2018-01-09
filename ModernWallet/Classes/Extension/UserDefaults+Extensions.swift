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
    
    var tempEmail: String? {
        get { return string(forKey: UserDefaults.keys.tempEmail) }
        set { set(newValue, forKey: UserDefaults.keys.tempEmail) }
    }
    
    var tempPhone: String? {
        get { return string(forKey: UserDefaults.keys.tempPhone) }
        set { set(newValue, forKey: UserDefaults.keys.tempPhone) }
    }
    
    var signUpStep: SignUpStep? {
        get { return SignUpStep(rawValue: integer(forKey: UserDefaults.keys.signUpStep)) }
        set { set(newValue?.rawValue, forKey: UserDefaults.keys.signUpStep) }
    }
    
    var isLoggedIn: Bool {
        get { return bool(forKey: UserDefaults.keys.loggedIn) }
        set { set(newValue, forKey: UserDefaults.keys.loggedIn) }
    }
    
    var isNotLoggedIn: Bool {
        return !isLoggedIn
    }

    func nulifySignUpStep() {
        signUpStep = nil
        synchronize()
    }
    
}
