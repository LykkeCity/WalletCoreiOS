//
//  LWRxAuthManagerAllAssetsMock.swift
//  WalletCoreTests
//
//  Created by Georgi Stanev on 3.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift
@testable import WalletCore

class LWRxAuthManagerAllAssetsMock: LWRxAuthManagerAllAssetsProtocol {
    func request(byId id: String?) -> Observable<ApiResult<LWAssetModel?>> {
        return Observable
            .just(ApiResult.success(withData: LWAssetModel()))
            .startWith(.loading)
    }
    
    func request() -> Observable<ApiResultList<LWAssetModel>> {
        return Observable<ApiResultList<LWAssetModel>>
            .just(ApiResultList.success(withData: [
                LWAssetModel()
            ]))
            .startWith(ApiResultList.loading)
    }
}
