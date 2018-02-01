//
//  LWRxAuthManagerOffchainRequests.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerOffchainRequests : NSObject{
    
    public typealias Packet = LWPacketOffchainRequests
    public typealias Result = ApiResult<[LWModelOffchainRequest]>
    public typealias ResultType = [LWModelOffchainRequest]
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

extension LWRxAuthManagerOffchainRequests: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketOffchainRequests {
        return Packet(observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.models)
    }
}
