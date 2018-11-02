//
//  LWRxAuthManagerGetBlockchainAddress.swift
//  WalletCore
//
//  Created by Nacho Nachev  on 10.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerGetBlockchainAddress: NSObject {
    public typealias Packet = LWPacketGetBlockchainAddress
    public typealias Result = ApiResult<LWPacketGetBlockchainAddress>
    public typealias ResultType = LWPacketGetBlockchainAddress
    public typealias RequestParams = String
    
    override init() {
        super.init()
        subscribe(observer: self, succcess: #selector(self.successSelector(_:)), error: #selector(self.errorSelector(_:)))
    }
    
    deinit {
        unsubscribe(observer: self)
    }
    
    @objc func successSelector(_ notification: NSNotification) {
        onSuccess(notification)
    }
    
    @objc func errorSelector(_ notification: NSNotification) {
        onError(notification)
    }
}


extension LWRxAuthManagerGetBlockchainAddress: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: String) -> LWPacketGetBlockchainAddress {
        return Packet(observer: observer, assetId: params)
    }
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        //try to get the address value from the cache
        guard let blockchainAddress = ((LWCache.instance()?.allAssets as? [LWAssetModel])?
                .first{ $0.identity == params })?
                .blockchainDepositAddress
            else {
                return self.defaultRequestImplementation(with: params)
                .do(onNext: { result in
                    guard let assetsFromCache = LWCache.instance()?.allAssets as? [LWAssetModel],
                        let receivedAsset = result.getSuccess() else { return }
                    //Add the address to the existing cache
                    assetsFromCache
                        .first(where: { $0.identity == receivedAsset.assetId })?
                        .blockchainDepositAddress = receivedAsset.address //set the address
                })
                .do(onNext: { _ in
                    NotificationCenter.default.post(name: .blockchainAddressReceived, object: nil)
                })
        }

        return Observable
            .just(ApiResult.success(withData: LWPacketGetBlockchainAddress(assetId: params, address: blockchainAddress)))
            .startWith(.loading)
    }
}


extension LWPacketGetBlockchainAddress {
    convenience init(observer: Any, assetId: LWRxAuthManagerGetBlockchainAddress.RequestParams) {
        self.init()
        self.observer = observer
        self.assetId = assetId
    }
    
    convenience init(assetId: String,address: String) {
        self.init()
        self.assetId = assetId
        self.address = address
    }
}
