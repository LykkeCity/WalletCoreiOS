//
//  CashOutBankAccountViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 27.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class CashOutBankAccountViewModel {
    
    public let bankName = Variable("")
    
    public let iban = Variable("")
    
    public let bic = Variable("")
    
    public let accountHolder = Variable("")
    
    public let accountHolderAddress = Variable("")
    
    public let accountHolderCountry = Variable("")

    public let accountHolderCountryCode = Variable("")

    public let accountHolderZipCode = Variable("")
    
    public let accountHolderCity = Variable("")
    
    public let isValid: Observable<Bool>
    
    private let isValidFields: Observable<Bool>
    
    private let isValidIBAN: Observable<Bool>

    private let isValidBIC: Observable<Bool>
    
    public init() {
        isValidFields = Observable.combineLatest([
            bankName.asObservable(),
            iban.asObservable(),
            bic.asObservable(),
            accountHolder.asObservable(),
            accountHolderAddress.asObservable(),
            accountHolderCountry.asObservable(),
            accountHolderCountryCode.asObservable(),
            accountHolderZipCode.asObservable(),
            accountHolderCity.asObservable()
            ])
            .map {
                for value in $0 {
                    if value.isEmpty {
                        return false
                    }
                }
                
                return true
        }
        
        isValidIBAN = iban.asObservable()
            .map { iban in
                iban.isValidIban()
        }
        
        isValidBIC = bic.asObservable()
            .map { bic in
                bic.isValidBic()
        }
        
        isValid = Observable.combineLatest([
            isValidFields,
            isValidIBAN,
            isValidBIC
            ])
            .map {
                for value in $0 {
                    if !value {
                        return false
                    }
                }
                
                return true
        }
    }
    
}
