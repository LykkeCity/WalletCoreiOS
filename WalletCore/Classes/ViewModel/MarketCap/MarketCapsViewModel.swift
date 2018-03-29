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

public class MarketCapsViewModel {
    
    public let loadingViewModel: LoadingViewModel
    public let success: Driver<[MarketCapViewModel]>
    public let errors: Driver<[AnyHashable: Any]>
    
    private let marketCaps = Variable<[LWModelMarketCapResult]>([])
    private let disposeBag = DisposeBag()
    
    /// - Parameters:
    /// - trigger    : A trigger to start the request
    /// - startIndex : A start index to fetch the items from as ranked at coinmarketcap.com
    /// - limt       : A limit of items to fetch
    /// - authManager: An AuthManager instance
    public init(trigger: Observable<Void>, limit: Int = 50, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let marketCapResultObservable = trigger
            .flatMapLatest{ [marketCaps] _ in
                authManager.marketCap.request(withParams: LWPacketMarketCap.Body(startIndex: marketCaps.value.count, limit: limit))
            }
            .shareReplay(1)
        
        self.loadingViewModel = LoadingViewModel([
            marketCapResultObservable.isLoading()
        ])
        
        self.errors = marketCapResultObservable
            .filterError()
            .asDriver(onErrorJustReturn: [:])
        
        self.success = marketCaps.asObservable()
            .map{ $0.map{ MarketCapViewModel($0) } }
            .asDriver(onErrorJustReturn: [])
        
        /// MARK: Bindings
        marketCapResultObservable
            .filterSuccess()
            .map{ [marketCaps] fetchedMarketCaps in [marketCaps.value, fetchedMarketCaps].flatMap{ $0 } }
            .bind(to: marketCaps)
            .disposed(by: disposeBag)
    }
}
