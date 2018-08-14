//
//  ValidateHintViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ValidateHintViewModel {
    
    // IN:
    /// Hint
    public let hint = Variable<String>("")
    
    // OUT:
    /// Validity of the hint
    public let isHintValid: Observable<Bool>
    
    private let disposeBag = DisposeBag()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        self.isHintValid = hint.asObservable()
            .map { $0.count >= 3 }
    }
}
