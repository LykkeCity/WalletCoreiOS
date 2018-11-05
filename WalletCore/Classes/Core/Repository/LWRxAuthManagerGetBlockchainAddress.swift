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
    
    var cache: LWCache {
        get { return LWCache.instance() }
    }
    
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
        if let blockchainAddress = cache.getAsset(byId: params)?.blockchainDepositAddress {
            return Observable
                .just(.success(withData:
                    LWPacketGetBlockchainAddress(assetId: params, address: blockchainAddress)
                ))
                .startWith(.loading)
        }
        
        return defaultRequestImplementation(with: params)
            .updateDepositAddress(inCache: cache)
            .postWhenSuccess(notification: .blockchainAddressReceived)
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

fileprivate extension ObservableType where Self.E == ApiResult<LWPacketGetBlockchainAddress> {
    
    /// Update the cache when receive new deposit address
    ///
    /// - Parameter cache: Cache to update
    /// - Returns: Observable
    func updateDepositAddress(inCache cache: LWCache) -> Observable<ApiResult<LWPacketGetBlockchainAddress>> {
        return `do`(onNext: { result in
            guard
                let receivedAsset = result.getSuccess(),
                let cachedAsset = cache.getAsset(byId: receivedAsset.assetId)
                else { return }
            //Add the address to the existing cache

            cachedAsset.blockchainDepositAddress = receivedAsset.address
        })
    }
}
