//
//  LWRxAuthManagerGetEncodedPrivateKey.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 24.09.18.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerGetEncodedPrivateKey: NSObject {
    
    public typealias Packet = LWPacketEncodedPrivateKey
    public typealias Result = ApiResult<LWPacketEncodedPrivateKey>
    public typealias ResultType = LWPacketEncodedPrivateKey
    public typealias RequestParams = String?
    
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

extension LWRxAuthManagerGetEncodedPrivateKey: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: LWRxAuthManagerGetEncodedPrivateKey.RequestParams) -> LWPacketEncodedPrivateKey {
        return Packet(observer: observer, token: params)
    }
}

extension LWPacketEncodedPrivateKey {
    convenience init(observer: Any, token: LWRxAuthManagerGetEncodedPrivateKey.RequestParams) {
        self.init()
        self.observer = observer
        self.accessToken = token
    }
}
