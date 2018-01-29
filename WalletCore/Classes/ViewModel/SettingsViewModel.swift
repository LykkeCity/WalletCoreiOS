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
    public let shouldSignOrder: Variable<Bool>
    public let result: Driver<ApiResult<LWPacketPersonalData>>
    public let resultShouldSignOrder: Driver<LWPacketSettingSignOrder>
    
    public let personalData: Driver<LWPersonalDataModel>
    
    public let appSettings: Driver<LWAppSettingsModel>
    
    public let loadingViewModel: LoadingViewModel
    
    private let disposeBag = DisposeBag()
    
    public init( authManager: LWRxAuthManager = LWRxAuthManager.instance,
                 lwCache: LWCache = LWCache.instance())
    {
        shouldSignOrder = Variable<Bool>(lwCache.shouldSignOrder)
        
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
        
        appSettingsRequestObservable
            .filterSuccess()
            .filter { $0.appSettings != nil }
            .map {$0.appSettings.shouldSignOrders }
            .bind(to: shouldSignOrder)
            .disposed(by: disposeBag)
        
        let shouldSignOrderObserver = shouldSignOrder
            .asObservable()
            .filter{ $0 != LWCache.instance().shouldSignOrder}
            .flatMap{ signOrder -> Observable<ApiResult<LWPacketSettingSignOrder>> in
                    return authManager.settingSignOrder.request(withParams: signOrder)
            }
            .shareReplay(1)

        resultShouldSignOrder = shouldSignOrderObserver
            .filterSuccess()
            .asDriver(onErrorJustReturn: LWPacketSettingSignOrder(json: []))
        
        loadingViewModel = LoadingViewModel([personalDataObservable.isLoading(),
                                             appSettingsRequestObservable.isLoading(),
                                             shouldSignOrderObserver.isLoading()
                                             ])
        loading = loadingViewModel.isLoading
    }
    
}

