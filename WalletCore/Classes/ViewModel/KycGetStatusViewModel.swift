//
//  KycGetStatusViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 30/07/18.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class KycGetStatusViewModel {
    
    /// UserDefaults key for `KYC approval screen is shown` boolean
    public static let kycSaveKey: String = "KycApprovalScreenShownToUser"
    
    /// Loading indicator
    public let loadingViewModel: LoadingViewModel
    
    /// An observable which receives the status check event
    public let kycStatusОк: Observable<Void>
    
    public init(_ authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        let kycStatusGet = authManager
            .kycStatusGet
            .request()
            .shareReplay(1)
        
        self.kycStatusОк = UserDefaults.standard.rx
            .observe(String.self, KycGetStatusViewModel.kycSaveKey)
            .map { storedValue in
                guard let storedValue = storedValue else {
                    // No value yet added to UserDefaults (fresh install)
                    return true
                }
                
                return storedValue != LWKeychainManager.instance().login
            }
            .filter { $0 }
            .flatMapLatest { _ in kycStatusGet }
            .filterSuccess()
            .filter { $0.status.lowercased() == "ok" }
            .map{ _ in () }
        
        self.loadingViewModel = LoadingViewModel([
            kycStatusGet.isLoading()
        ])
    }
}


//kycPendingVC

