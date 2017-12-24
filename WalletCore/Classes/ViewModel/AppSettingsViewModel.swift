//
//  AppSettingsViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/28/17.
//
//

import Foundation
import RxSwift
import RxCocoa


open class AppSettingsViewModel: NSObject { 
    public let loading: Observable<Bool>
    public let resultAppSettings: Driver<ApiResult<LWPacketAppSettings>>
    public let resultAllCurrencies: Driver<ApiResultList<LWAssetModel>>
    public let resultPushNotifications: Driver<ApiResult<LWPacketPushSettingsGet>>
    public let resultAccount: Driver<ApiResult<LWPacketAccountExist>>
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        //LWKeychainManager.instance().login!
        resultAppSettings = authManager.appSettings.request().asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        resultAllCurrencies = authManager.allAssets.request().asDriver(onErrorJustReturn: ApiResultList.error(withData: [:]))
        resultPushNotifications = authManager.pushNotGet.request().asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        resultAccount = authManager.accountExist.request(withParams: LWKeychainManager.instance().login).asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        let m = Observable.merge([self.resultAppSettings.asObservable().isLoading(), self.resultAllCurrencies.asObservable().isLoading(),
                                  self.resultPushNotifications.asObservable().isLoading(), self.resultAccount.asObservable().isLoading()])
        loading = m
    }
    
}


