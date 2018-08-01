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
    
    /// Loading indicator
    public let loadingViewModel: LoadingViewModel
    
    /// An observable which receives the status check event
    public let kycStatusОк: Observable<Void>
    
    public init(_ authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        let kycStatusGet = authManager
            .kycStatusGet
            .request()
            .shareReplay(1)
        
        self.kycStatusОк = kycStatusGet
            .filterSuccess()
            .filter { kycStatus in
                kycStatus.status == "Ok"
            }
            .map{ _ in () }
        
        self.loadingViewModel = LoadingViewModel([
            kycStatusGet.isLoading()
        ])
    }
}


//kycPendingVC

