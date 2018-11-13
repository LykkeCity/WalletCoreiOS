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
    
    //IN
    public let pinTrigger = PublishSubject<String>()
    
    //OUT
    public let result: Observable<LWPacketPinSecurityGet>
    
    public let error: Observable<[AnyHashable: Any]>
    
    public let loadingViewModel: LoadingViewModel
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        let request = pinTrigger
            .throttle(1, scheduler: MainScheduler.instance)
            .flatMapLatest{ pin in
                authManager.pinget.request(withParams: pin)
            }
            .shareReplay(1)
        
        result = request.filterSuccess()
        
        error = request.filterError()
        
        loadingViewModel = LoadingViewModel([request.asObservable().isLoading()])
    }
}
