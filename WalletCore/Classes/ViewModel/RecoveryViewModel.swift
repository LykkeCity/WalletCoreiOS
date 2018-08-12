//
//  RecoveryViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class RecoveryViewModel {
    public let email = Variable<String>("")
    public let signedOwnershipMessage = Variable<String>("")
    public let smsCode = Variable<String>("")
    public let newPin = Variable<String>("")
    public let newPassword = Variable<String>("")

//    public let resendSmsData: Observable<(phone: String, signedOwnershipMessage: String)>
//
//    public let success: Observable<Void>
//
//    public let errors: Observable<[AnyHashable: Any]>
//
//    public let loadingViewModel: LoadingViewModel
    
    public lazy var isValidSmsCode: Observable<Bool> = {
        return self.smsCode.asObservable()
            .map { $0.count >= 4 }
            .debug()
    }()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
    }
}
