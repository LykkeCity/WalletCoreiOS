//
//  LWRxAuthManagerOffchainProcessChannel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerOffchainProcessChannel : NSObject{
    
    public typealias Packet = LWPacketOffchainProcessChannel
    public typealias Result = ApiResult<LWModelOffchainResult>
    public typealias ResultType = LWModelOffchainResult
    public typealias RequestParams = (LWPacketOffchainProcessChannel.Body)
    
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

extension LWRxAuthManagerOffchainProcessChannel: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: (LWPacketOffchainProcessChannel.Body)) -> LWPacketOffchainProcessChannel {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.model!)
    }
}
