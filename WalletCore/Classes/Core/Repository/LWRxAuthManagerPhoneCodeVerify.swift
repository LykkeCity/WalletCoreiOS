//
//  LWRxAuthManagerPhoneCodeVerify.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 24.09.18.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerPhoneCodeVerify: NSObject {
    
    public typealias Packet = LWPacketSendVerificationCode
    public typealias Result = ApiResult<LWPacketSendVerificationCode>
    public typealias ResultType = LWPacketSendVerificationCode
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


extension LWRxAuthManagerPhoneCodeVerify: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: LWRxAuthManagerPhoneCodeVerify.RequestParams) -> LWPacketSendVerificationCode {
        return Packet(observer: observer, params: params)
    }
}

extension LWPacketSendVerificationCode {
    convenience init(observer: Any, code: LWRxAuthManagerPhoneCodeVerify.RequestParams) {
        self.init()
        self.observer = observer
        self.code = code
    }
}
