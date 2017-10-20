//
//  PushNotificationsViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/29/17.
//
//

import Foundation
import RxSwift
import RxCocoa

open class PushNotificationsViewModel {
    
    public let on = Variable<Bool>(true)
    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketPushSettingsSet>>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPushNotification(on: on, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loading = result.asObservable().isLoading()
    }

}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPushNotification(
        on: Variable<Bool>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketPushSettingsSet>> {
        
        return flatMapLatest{authData in
            authManager.pushNotSet.setPushNotifications(isOn : on.value)
            }
            .shareReplay(1)
    }
}

