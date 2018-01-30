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
    
    public lazy var assetsViewModel : AssetsViewModel = {
        return AssetsViewModel(withAssets: self.result,
                               selectedAsset: LWRxAuthManager.instance.baseAsset.request(),
                               dependency: AssetsViewModel.Dependency(authManager: LWRxAuthManager.instance,
                                                                      formatter: SingleAssetFormatter()))
    }()
    
    /// Standart loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Standart error driver
    public let errors: Driver<[AnyHashable: Any]>
    
    private var result: Observable<ApiResultList<LWAssetModel>>
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = authManager.allAssets.request().filterSuccess()
            .map { _ in return () }
            .mapAssets(authManager: authManager)
        
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
