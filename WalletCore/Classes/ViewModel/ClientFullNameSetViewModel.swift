//
//  ClientFullNameSetViewModel.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 9/6/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

open class ClientFullNameSetViewModel {
    
    public let clientFullNameSet : Observable<LWPacketClientFullNameSet>
    public let loadingViewModel: LoadingViewModel
    
    public let firstName = Variable<String>("")
    public let lastName = Variable<String>("")
    
    public init(trigger: Observable<Void>, authManagerInternal : LWRxAuthManager = LWRxAuthManager.instance) {
        
        
        let setClientFullName = trigger
            .mapToPack(firstName: self.firstName, lastName: self.lastName, authManager: authManagerInternal)
            .shareReplay(1)
        
        self.clientFullNameSet = setClientFullName.filterSuccess()

        loadingViewModel = LoadingViewModel([
            setClientFullName.isLoading()
            ])
        
        
    }
    
    public var isValid : Observable<Bool>{
        return Observable.combineLatest( self.firstName.asObservable(), self.lastName.asObservable(), resultSelector:
            {(firstName, lastName) -> Bool in
                return firstName.characters.count > 2
                    && lastName.characters.count > 2
        })
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        firstName: Variable<String>,
        lastName: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketClientFullNameSet>> {
        
        return flatMapLatest{_ in
             authManager.setFullName.request(withParams: "\(firstName.value) \(lastName.value)")}
            }
    }
