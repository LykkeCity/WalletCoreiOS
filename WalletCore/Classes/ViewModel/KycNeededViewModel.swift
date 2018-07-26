//
//  KycNeededViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class KycNeededViewModel {

    /// Loading indicator
    public let loadingViewModel: LoadingViewModel

    /// An observable which receive events for opening KYC.If false proceed, if true open KYC.
    public let ok: Observable<Void>

    public let pending: Observable<Void>

    public let needToFillData: Observable<Void>

    public init(forAsset asset: Observable<ApiResult<LWAssetModel>>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        let kycForAsset = asset
            .filterSuccess()
            .flatMapLatest {asset in
                return LWRxAuthManager.instance.kycForAsset.request(withParams: asset.identity)
            }
            .shareReplay(1)

        self.ok = kycForAsset
            .filterSuccess()
            .filter {kycForAsset in
                kycForAsset.userKYCStatus == "Ok"
            }
            .map {_ in Void()}

        self.pending = kycForAsset
            .filterSuccess()
            .filter {kycForAsset in
                kycForAsset.userKYCStatus == "Pending"
            }
            .map {_ in Void()}

        self.needToFillData = kycForAsset
            .filterSuccess()
            .filter {kycForAsset in
                kycForAsset.userKYCStatus == "NeedToFillData" // && kycForAsset.kycNeeded
            }
            .map {_ in Void()}

        self.loadingViewModel = LoadingViewModel([
            asset.isLoading(),
            kycForAsset.isLoading()
        ])
    }
}

//kycPendingVC
