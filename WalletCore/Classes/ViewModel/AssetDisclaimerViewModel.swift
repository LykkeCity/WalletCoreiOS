//
//  AssetDisclaimerViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 11.05.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class AssetDisclaimerViewModel {
    
    public var disclaimer: Driver<LWModelAssetDisclaimer>
    public let loadingViewModel: LoadingViewModel
    public let dismissViewController: Driver<Void>
    
    private let disclaimers = Variable<[LWModelAssetDisclaimer]>([])
    private let disposeBag = DisposeBag()
    
    public init(
        accept: Driver<AssetDisclaimerId>,
        decline: Driver<AssetDisclaimerId>,
        acceptEnabled: Driver<Bool>,
        authManager: LWRxAuthManager = LWRxAuthManager.instance
    ) {
        
        /// Properties
        let disclaimerRequest = authManager.assetDisclaimers.request()
        
        let disclaimerAcceptRequest = accept.asObservable()
            .accept(isAcceptEnabled: acceptEnabled, authManager: authManager)
        
        let nextDisclaimerToAccept = disclaimerAcceptRequest
            .mapToNextDisclaimer(fromDisclaimers: disclaimers.value)
        
        let disclaimerDeclineRequest = decline.asObservable()
            .flatMapLatest{
                authManager.assetDisclaimerDecline.request(withParams: $0)
            }
            .shareReplay(1)
        
        disclaimer = Driver.merge([
            disclaimers.asObservable().mapToFirst(),
            nextDisclaimerToAccept.asDriver(onErrorJustReturn: nil).filterNil()
        ])
        
        dismissViewController =
            Observable.merge(
                disclaimerDeclineRequest.filterSuccess().map{ _ in () },
                nextDisclaimerToAccept.filter{ $0 == nil }.map{ _ in () }
            )
            .asDriver(onErrorJustReturn: ())
        
        loadingViewModel = LoadingViewModel([
            disclaimerRequest.isLoading(),
            disclaimerAcceptRequest.isLoading(),
            disclaimerDeclineRequest.isLoading()
        ])
        
        
        /// Bindings
        disclaimerRequest
            .filterSuccess()
            .bind(to: disclaimers)
            .disposed(by: disposeBag)
    }
}

fileprivate extension ObservableType where Self.E == LWRxAuthManagerAssetDisclaimersApprove.Result {
    
    /// <#Description#>
    ///
    /// - Parameter disclaimers: <#disclaimers description#>
    /// - Returns: <#return value description#>
    func mapToNextDisclaimer(fromDisclaimers disclaimers: [LWModelAssetDisclaimer]) -> Observable<LWModelAssetDisclaimer?> {
        return filterSuccess().map{ disclaimer -> LWModelAssetDisclaimer? in
            guard let indexOfAcceptedDisclaimer = (disclaimers.index{ $0.id == disclaimer }) else {
                return nil
            }
            
            return disclaimers[opt: indexOfAcceptedDisclaimer + 1 ]
        }
    }
}

fileprivate extension ObservableType where Self.E == AssetDisclaimerId {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - acceptEnabled: <#acceptEnabled description#>
    ///   - authManager: <#authManager description#>
    /// - Returns: <#return value description#>
    func accept(isAcceptEnabled acceptEnabled: Driver<Bool>, authManager: LWRxAuthManager) -> Observable<LWRxAuthManagerAssetDisclaimersApprove.Result>  {
        return
            withLatestFrom(acceptEnabled) { (disclaimer: $0, enabled: $1) }
            .filter{ $0.enabled }
            .map{ $0.disclaimer }
            .flatMapLatest{ disclaimerId in
                authManager.assetDisclaimerAccept.request(withParams: disclaimerId)
            }
            .shareReplay(1)
    }
}

fileprivate extension ObservableType where Self.E == [LWModelAssetDisclaimer] {
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func mapToFirst() -> Driver<LWModelAssetDisclaimer> {
        return map{ $0.first }
            .asDriver(onErrorJustReturn: nil)
            .filterNil()
    }
}
