//
//  MarketCapViewModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 8.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class MarketCapViewModel {
    
    public let loadingViewModel: LoadingViewModel
    
    public let success: Driver<[LWModelMarketCapResult]>
    
    public let errors: Driver<[AnyHashable: Any]>
        
    private let disposeBag = DisposeBag()
    
    /// - Parameters:
    /// - trigger    : A trigger to start the request
    /// - startIndex : A start index to fetch the items from as ranked at coinmarketcap.com
    /// - limt       : A limit of items to fetch
    /// - authManager: An AuthManager instance
    public init(trigger: Observable<Void>, startIndex: Int, limit: Int, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        let marketCapResultObservable = trigger.flatMapLatest{ _ in
            authManager.marketCap.request(withParams: LWPacketMarketCap.Body(startIndex: startIndex, limit: limit))
        }.shareReplay(1)
        
        loadingViewModel = LoadingViewModel([
            marketCapResultObservable.map{ $0.isLoading }
            ])
        
        success = marketCapResultObservable
            .filterSuccess()
            .asDriver(onErrorJustReturn: [LWModelMarketCapResult.empty])
        
        errors = marketCapResultObservable
            .map{ $0.getError() }
            .filterNil()
            .asDriver(onErrorJustReturn: [:])
    }
    
}
