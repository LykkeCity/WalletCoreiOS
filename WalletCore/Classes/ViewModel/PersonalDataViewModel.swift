//
//  PersonalDataViewModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 11/27/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class PersonalDataViewModel {
    public let email: Driver<String>
    public let loading: LoadingViewModel
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        let personalData = authManager.settings.request()
        
        self.email = personalData
            .filterSuccess()
            .map{ $0.data.email }
            .asDriver(onErrorJustReturn: "")
        
        self.loading = LoadingViewModel([personalData.isLoading()])
    }
}
