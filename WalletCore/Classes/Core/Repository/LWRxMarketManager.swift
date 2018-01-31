//
//  LWRxMarketManager.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxMarketManager: NSObject  {
    
    public typealias Packet = LWPacketMarket
    public typealias Result = ApiResult<[LWMarketModel]>
    public typealias ResultType = [LWMarketModel]
    public typealias RequestParams = Void
    
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

extension LWRxMarketManager: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketMarket {
        return Packet(observer: observer)
    }

    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.marketAssetPairs.map{$0 as! LWMarketModel})
    }
}

public extension ObservableType where Self.E == ApiResult<[LWMarketModel]> {
    public func filterSuccess() -> Observable<[LWMarketModel]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
