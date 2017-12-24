//
//  CashOutGeneralViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 27.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class CashOutGeneralViewModel {
    
    public let name = Variable("")
    
    public let transactionReason = Variable("")
    
    public let additionalNotes = Variable("")
    
    public let isValid: Observable<Bool>
    
    public init() {
        isValid = name.asObservable()
            .map { $0.isNotEmpty }
    }
    
}
