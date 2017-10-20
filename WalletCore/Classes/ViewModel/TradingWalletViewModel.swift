//
//  TradingWalletViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 9/5/17.
//
//


import Foundation
import UIKit
import RxSwift
import RxCocoa
//LWPacketWallets
open class TradingWalletViewModel {

    public let loading: Observable<Bool>
    public let result: Driver<ApiResult<LWLykkeWalletsData>>
    
    public init(submit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        let pairsObservable = authManager.assetPairs.requestAssetPairs()
        result = submit.throttle(1, scheduler: MainScheduler.instance).mapToPack(authManager: authManager).asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
      //  loading = result.asObservable().isLoading()
        
        let m = Observable.merge([self.result.asObservable().isLoading(), pairsObservable.asObservable().isLoading()])
        loading = m
    }

}

fileprivate extension ObservableType where Self.E == Void {
    func mapToPack(
            authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWLykkeWalletsData>> {
        
        return flatMapLatest{authData in
            authManager.lykkeWallets.requestLykkeWallets()
            }
            .shareReplay(1)
    }
}
