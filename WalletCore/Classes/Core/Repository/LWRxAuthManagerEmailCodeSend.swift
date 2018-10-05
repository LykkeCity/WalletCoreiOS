//
//  LWRxAuthManagerEmailCodeSend.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 24.09.18.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerEmailCodeSend: NSObject {
    
    public typealias Packet = LWPacketEmailVerificationSet
    public typealias Result = ApiResult<LWPacketEmailVerificationSet>
    public typealias ResultType = LWPacketEmailVerificationSet
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

extension LWRxAuthManagerEmailCodeSend: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: LWRxAuthManagerEmailCodeSend.RequestParams) -> LWPacketEmailVerificationSet {
        return Packet(observer: observer, data: params)
    }
}
