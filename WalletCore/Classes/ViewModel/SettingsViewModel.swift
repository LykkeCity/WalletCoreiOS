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
    
    public let personalData: Driver<LWPersonalDataModel>
    
    public let appSettings: Driver<LWAppSettingsModel>
    
    public let loadingViewModel: LoadingViewModel
    
    private let disposeBag = DisposeBag()
    
    public init( authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        let personalDataObservable = authManager.settings.request()
        result = personalDataObservable.asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        personalData = personalDataObservable
            .filterSuccess()
            .map { $0.data }
            .asDriver(onErrorJustReturn: LWPersonalDataModel())
        
        let appSettingsRequestObservable = authManager.appSettings.request()
        appSettings = appSettingsRequestObservable
            .filterSuccess()
            .filter { $0.appSettings != nil }
            .map { (packet: LWPacketAppSettings) in packet.appSettings! }
            .asDriver(onErrorJustReturn: LWAppSettingsModel())
        
        loadingViewModel = LoadingViewModel([personalDataObservable.isLoading(), appSettingsRequestObservable.isLoading()])
        loading = loadingViewModel.isLoading
    }

}

