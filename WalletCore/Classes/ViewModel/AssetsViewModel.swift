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

    public typealias AssetsList = Observable<ApiResult<[LWAssetModel]>>
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

    public init(withAssets assetsToFetch: AssetsList, dependency: Dependency) {

        self.assets = assetsToFetch
            .mapToViewModels(dependency: dependency)
            .asDriver(onErrorJustReturn: [])

        // Update the view models to update the selected one
        Observable.combineLatest(self.selectedAsset.asObservable(), self.assets.asObservable()) { (current: $0, all: $1) }
            .do(onNext: { data in
                data.all.forEach({ $0.isSelected.value = false })
            })
            .map { data in
                data.all.first { $0.asset.value.identity == data.current?.identity }
            }
            .filterNil()
            .subscribe(onNext: { viewModel in viewModel.isSelected.value = true })
            .disposed(by: disposeBag)

        // Simple loading (all assets)
        loadingViewModel = LoadingViewModel([assetsToFetch.isLoading()])

        // Simple error handling (all assets)
        errors = assetsToFetch.filterError()
            .asDriver(onErrorJustReturn: [:])
    }
}

fileprivate extension ObservableType where Self.E == ApiResult<[LWAssetModel]> {

    /// Transform asset model objects to `SingleAssetViewModel`
    ///
    /// - Parameter dependency: Dependency
    /// - Returns: Observable of array containing assets view model
    func mapToViewModels(dependency: AssetsViewModel.Dependency) -> Observable<[SingleAssetViewModel]> {
        return
            filterSuccess()
            .map { data in
                data.map { SingleAssetViewModel(
                    withAsset: Variable<LWAssetModel>($0),
                    formatter: dependency.formatter)
                }
            }
    }
}
