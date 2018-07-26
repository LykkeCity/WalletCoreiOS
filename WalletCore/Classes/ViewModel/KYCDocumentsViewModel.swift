//
//  KYCDocumentsViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/25/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class KYCDocumentsViewModel {

    /// Loading indicator
    public let loadingViewModel: LoadingViewModel

    /// Observable with LWKYCDocumentsModel.It changes when asset changes
    public let documents: Observable<LWKYCDocumentsModel>

    /// A driver with dictionary with error messages
    public let error: Driver<[AnyHashable: Any]>

    ///
    /// - Parameters:
    ///   - trigger: A observable that will trigger fetching documents
    ///   - asset: An asset used for KYC Documents
    ///   - authManager: AuthManager
    public init(
        trigger: Observable<Void>,
        forAsset asset: Observable<ApiResult<LWAssetModel>>,
        authManager: LWRxAuthManager = LWRxAuthManager.instance
    ) {
        let kycDocumentsResult = Observable.combineLatest(trigger, asset.filterSuccess()) {$1}
            .flatMapLatest {asset -> Observable<ApiResult<LWKYCDocumentsModel>> in
                return authManager.kycDocuments.request(withParams: asset.identity)
            }
            .shareReplay(1)

        self.documents = kycDocumentsResult
            .filterSuccess()

        self.error = Observable
            .merge(
                kycDocumentsResult.filterForbidden().map {["Message": "Requesting documents those documents is forbidden."]},
                kycDocumentsResult.filterError()
            )
            .asDriver(onErrorJustReturn: [:])

        self.loadingViewModel = LoadingViewModel([
            asset.isLoading(),
            kycDocumentsResult.isLoading()
        ])
    }
}
