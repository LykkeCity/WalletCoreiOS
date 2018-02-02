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
}


extension LWPacketGetBlockchainAddress {
    convenience init(observer: Any, assetId: LWRxAuthManagerGetBlockchainAddress.RequestParams) {
        self.init()
        self.observer = observer
        self.assetId = assetId
    }
}
