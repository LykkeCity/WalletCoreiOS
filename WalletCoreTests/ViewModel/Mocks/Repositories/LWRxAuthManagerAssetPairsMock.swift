//
//  FileLWRxAuthManagerAssetPairsMock.swift
//  WalletCoreTests
//
//  Created by Ivan Stefanovic on 1/19/18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift
@testable import WalletCore

class LWRxAuthManagerAssetPairsMock: LWRxAuthManagerAssetPairsProtocol {
    
    var data: [LWAssetPairModel]
    
    init(data: [LWAssetPairModel]) {
        self.data = data
    }
    func request(baseAsset: LWAssetModel, quotingAsset: LWAssetModel) -> Observable<ApiResult<LWAssetPairModel?>>{
        return Observable<ApiResult<LWAssetPairModel?>>
            .just(ApiResult.success(withData: data[0]))
            .startWith(.loading)
    }
    func request(byId id: String) -> Observable<ApiResult<LWAssetPairModel?>>{
        return Observable<ApiResult<LWAssetPairModel?>>
            .just(ApiResult.success(withData: data[0]))
            .startWith(.loading)
    }

    
    func request() -> Observable<ApiResultList<LWAssetPairModel>> {
        return Observable<ApiResultList<LWAssetPairModel>>
            .just(.success(withData: data))
            .startWith(.loading)
    }
    
   
}
