//
//  ApplicationInfoViewModel.swift
//  WalletCore
//
//  Created by Ivan Stefanovic on 1/25/18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class ApplicationInfoViewModel {
    public var applicationInfo : Observable<LWPacketApplicationInfo>
    public var termsOfUse : Observable<String>
    
    public var isLoading: Observable<Bool>
    
    public init(
        authManager:LWRxAuthManager = LWRxAuthManager.instance
        ) {
        
        let request = authManager.applicationInfo.request()
        
        isLoading = request.isLoading()
        
        applicationInfo =  request
            .asObservable()
            .filterSuccess()

        
        termsOfUse = applicationInfo
            .asObservable()
            .map{ $0.termsOfUse}
        
        
        
    }
}
