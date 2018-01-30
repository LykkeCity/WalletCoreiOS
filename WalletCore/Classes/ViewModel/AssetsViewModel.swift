//
//  AssetsViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class AssetsViewModel {
    
    public typealias Dependency = (
        authManager: LWRxAuthManager,
        formatter: SingleAssetFormatterProtocol
    )
    
    public typealias AssetsList = Observable<ApiResultList<LWAssetModel>>
    public typealias SelectedAsset = Observable<ApiResult<LWAssetModel>>
    
    /// Collection of view models fetched and transformed
    public let assets: Driver<[SingleAssetViewModel]>
    
    /// Selected asset (if present)
    public let selectedAsset = Variable<LWAssetModel?>(nil)
    
    /// Standart loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Standart error driver
    public let errors: Driver<[AnyHashable: Any]>
    
    let disposeBag = DisposeBag()
    
    public init(withAssets assets: AssetsList, dependency: Dependency) {
        self.assets = assets.filterSuccess()
            .map{ data in
                data.map { value in
                    print(value.self)
                    return SingleAssetViewModel(withAsset: Variable<LWAssetModel>(value), formatter: dependency.formatter)
                }
            }
            .asDriver(onErrorJustReturn: [])
        
        errors = assets.filterError()
            .asDriver(onErrorJustReturn: [:])
        
        loadingViewModel = LoadingViewModel([
            assets.isLoading()
        ])
    }
    
    convenience public init(withAssets assets: AssetsList, selectedAsset selected: SelectedAsset, dependency: Dependency) {
        self.init(withAssets: assets, dependency: dependency)
        
        selected.asObservable().filterSuccess()
            .bind(to: selectedAsset)
            .disposed(by: disposeBag)
    }
}
