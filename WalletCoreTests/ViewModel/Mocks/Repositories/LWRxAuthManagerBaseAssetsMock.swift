//
//  LWRxAuthManagerBaseAssetsMock.swift
//  WalletCoreTests
//
//  Created by Vladimir Dimov on 26.09.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift
@testable import WalletCore

class LWRxAuthManagerBaseAssetsMock: LWRxAuthManagerBaseAssetsProtocol {

    var asset: [LWAssetModel]
    
    init(asset: [LWAssetModel]) {
        self.asset = asset
    }
    
    func request() -> Observable<ApiResult<[LWAssetModel]>> {
        return Observable<ApiResult<[LWAssetModel]>>
            .just(ApiResult.success(withData: asset))
            .startWith(ApiResult.loading)
    }
    
    
}
