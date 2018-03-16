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
    
    /// The limit of assets to retrieve
    private static let limit = 20
    
    /// - Parameters:
    /// - trigger    : An observable to trigger getting the market cap data
    /// - startIndex : the index of an asset to start parsing from, as listed on coinmarketcap.com
    /// - authManager: AuthManager instance
    public init(trigger: Observable<Void>, startIndex: Int, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        let marketCapResult = authManager.marketCap.request(
            withParams: LWPacketMarketCap.Body(startIndex: startIndex, limit: MarketCapViewModel.limit)
        ).shareReplay(1)
        
        loadingViewModel = LoadingViewModel([
            marketCapResult.map{ $0.isLoading }
            ])
        
        success = marketCapResult
            .asObservable()
            .filterSuccess()
            .asDriver(onErrorJustReturn: [LWModelMarketCapResult.empty])
        
        errors = marketCapResult
            .map{ $0.getError() }
            .filterNil()
            .asDriver(onErrorJustReturn: [:])
    }
    
}
