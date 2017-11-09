//
//  PinGetViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/31/17.
//
//

import Foundation
import RxSwift
import RxCocoa

open class PinGetViewModel{
    
    public let pin = Variable<String>("")
    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketPinSecurityGet>>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPack(pin:pin, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loading = self.result.asObservable().isLoading()
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
        pin: Variable<String>,
        authManager: LWRxAuthManager
    ) -> Observable<ApiResult<LWPacketPinSecurityGet>> {
        
        return flatMapLatest{authData in
            authManager.pinget.request(withParams: pin.value)
        }
        .shareReplay(1)
    }
}
