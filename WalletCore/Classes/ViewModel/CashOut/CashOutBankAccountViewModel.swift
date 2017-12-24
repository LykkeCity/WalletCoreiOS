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
    
    public let isValid: Observable<Bool>
    
    public init() {
        isValid = Observable.combineLatest(
            bankName.asObservable(),
            iban.asObservable(),
            bic.asObservable(),
            accountHolder.asObservable()
            )
            .map { return
                $0.0.isNotEmpty &&
                    $0.1.isNotEmpty &&
                    $0.2.isNotEmpty &&
                    $0.3.isNotEmpty
        }
    }
    
}
