//
//  ReferralLinkViewModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/1/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class ReferralLinkViewModel {
    
    public let referralLinkUrl: Observable<String>
    
    public let loadingViewModel: LoadingViewModel
    
    public init(trigger: Observable<Void>, blueManager: LWRxBlueAuthManager = LWRxBlueAuthManager.instance) {
        let referralLink = trigger
            .flatMapLatest{ blueManager.referralLink.request() }
            .shareReplay(1)
        
        referralLinkUrl = referralLink
            .filterSuccess()
            .map{ $0.url }
        
        loadingViewModel = LoadingViewModel([referralLink.isLoading()])
    }
}
