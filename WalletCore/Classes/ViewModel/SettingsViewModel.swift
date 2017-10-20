//
//  SettingsViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/23/17.
//
//

import Foundation
import RxSwift
import RxCocoa

open class SettingsViewModel {

    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketPersonalData>>
    
    public init( authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
         result = authManager.settings.getPersonalData().asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loading = result.asObservable().isLoading()
    }

}

