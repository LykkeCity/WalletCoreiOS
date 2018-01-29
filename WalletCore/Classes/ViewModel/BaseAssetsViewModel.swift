//
//  BaseAssetsViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class BaseAssetsViewModel {
    public var assetsViewModel: AssetsViewModel!
    
    /// Standart loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Standart error driver
    public let errors: Driver<[AnyHashable: Any]>
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        let result = authManager.allAssets.request().filterSuccess()
            .throttle(1, scheduler: MainScheduler.instance)
            .map { _ in return () }
            .mapAssets(authManager: authManager)
        
        let dependency = AssetsViewModel.Dependency(authManager: authManager, formatter: SingleAssetFormatter())
        
        assetsViewModel = AssetsViewModel(withAssets: result, selectedAsset: authManager.baseAsset.request(), dependency: dependency)
        
        // Loading and error handling
        loadingViewModel = LoadingViewModel([result.isLoading()])
        errors = result.filterError()
            .asDriver(onErrorJustReturn: [:])
    }
}

fileprivate extension ObservableType where Self.E == Void {
    
    func mapAssets(
        authManager: LWRxAuthManager
        ) -> Observable<ApiResultList<LWAssetModel>> {
        
        return flatMapLatest { _ in authManager.baseAssets.request() }
            .shareReplay(1)
    }
}
