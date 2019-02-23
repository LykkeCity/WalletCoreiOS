//
//  LWRxAuthManagerOffchainChannelKey.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerOffchainChannelKey : NSObject{
    
    public typealias Packet = LWPacketOffchainChannelKey
    public typealias Result = ApiResult<LWModelOffchainChannelKey>
    public typealias ResultType = LWModelOffchainChannelKey
    public typealias RequestParams = (String)
    
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

extension LWRxAuthManagerOffchainChannelKey: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketOffchainChannelKey {
        return Packet(assetId: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.model!)
    }
}
