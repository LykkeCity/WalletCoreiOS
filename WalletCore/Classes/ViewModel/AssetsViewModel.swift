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
    
    /// Collection of view models fetched and transformed
    public let assets: Driver<[SingleAssetViewModel]>
    
    /// Current asset (if present)
    public let currentAsset = Variable<LWAssetModel?>(nil)
    
    /// Standart loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Standart error driver
    public let errors: Driver<[AnyHashable: Any]>
    
    let disposeBag = DisposeBag()
    
    public init(
        withAssets assets: Observable<ApiResultList<LWAssetModel>>,
        dependency: Dependency
    ) {
        self.assets = Observable.combineLatest(assets.filterSuccess(), currentAsset.asObservable()) {(all: $0, current: $1)}
            .map{ data in
                data.all.map {
                    let viewModel = SingleAssetViewModel(withAsset: Observable.of($0), formatter: dependency.formatter)
                    viewModel.isSelected.value = ($0.identity == data.current?.identity)
                    return viewModel
                }
            }
            .asDriver(onErrorJustReturn: [])
        
        errors = assets.filterError()
            .asDriver(onErrorJustReturn: [:])
        
        loadingViewModel = LoadingViewModel([
            assets.isLoading()
        ])
    }
}
