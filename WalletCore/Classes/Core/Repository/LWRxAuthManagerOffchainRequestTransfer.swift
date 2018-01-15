//
//  LWRxAuthManagerRequestTransfer.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerOffchainRequestTransfer : NSObject{
    
    public typealias Packet = LWPacketRequestTransfer
    public typealias Result = ApiResult<LWModelOffchainResult>
    public typealias RequestParams = (LWPacketRequestTransfer.Body)
    
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

extension LWRxAuthManagerOffchainRequestTransfer: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (LWPacketRequestTransfer.Body)) -> LWPacketRequestTransfer {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet.model!)
    }
}

