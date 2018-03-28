//
//  LWRxAuthManagerMarketCap.swift
//  WalletCore
//
//  Created by Vasil Garov on 7.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerMarketCap: NSObject {
    
    public typealias Packet = LWPacketMarketCap
    public typealias Result = ApiResult<[LWModelMarketCapResult]>
    public typealias ResultType = [LWModelMarketCapResult]
    public typealias RequestParams = LWPacketMarketCap.Body
    
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

extension LWRxAuthManagerMarketCap: AuthManagerProtocol {
    
    public func request(withParams params: RequestParams) -> Observable<Result> {
        if let marketCaps = LWCache.instance().marketCaps as? [LWModelMarketCapResult] {
            return Observable
                .just(ApiResult.success(withData: marketCaps))
                .startWith(ApiResult.loading)
        }
        
        return defaultRequestImplementation(with: params)
    }
    
    public func createPacket(withObserver observer: Any, params: LWPacketMarketCap.Body) -> LWPacketMarketCap {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        LWCache.instance().marketCaps = packet.models
        return Result.success(withData: packet.models)
    }
}
