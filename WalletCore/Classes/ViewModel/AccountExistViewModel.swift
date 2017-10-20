//
//  AccountExistViewModel.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/28/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class AccountExistViewModel {
    
    public let accountExistObservable : Observable<LWPacketAccountExist>
    public let isLoading: Observable<Bool>
    
    public init(email: Observable<String>, authManager:LWRxAuthManager = LWRxAuthManager.instance) {
        let observable = email
            .throttle(0.5, scheduler: MainScheduler.instance)
            .flatMapLatest{email in authManager.accountExist.requestAccountExist(email: email)}
            .shareReplay(1)
        
        accountExistObservable = observable.filterSuccess()
        isLoading = observable.isLoading()
    }
}
