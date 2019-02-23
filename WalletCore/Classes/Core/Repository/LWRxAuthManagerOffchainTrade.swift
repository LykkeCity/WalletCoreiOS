//
//  LWRxAuthManagerOffchainTrade.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerOffchainTrade : NSObject{
    
    public typealias Packet = LWPacketOffchainTrade
    public typealias Result = ApiResult<LWModelOffchainResult>
    public typealias ResultType = LWModelOffchainResult
    public typealias RequestParams = (LWPacketOffchainTrade.Body)
    
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

extension LWRxAuthManagerOffchainTrade: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (LWPacketOffchainTrade.Body)) -> LWPacketOffchainTrade {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.model!)
    }
}
