//
//  LWRxAuthManagerEmailCodeVerify.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 24.09.18.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerEmailCodeVerify: NSObject {
    
    public typealias Packet = LWPacketEmailVerificationGet
    public typealias Result = ApiResult<LWPacketEmailVerificationGet>
    public typealias ResultType = LWPacketEmailVerificationGet
    public typealias RequestParams = (email: String, code: String, accessToken: String?)
    
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


extension LWRxAuthManagerEmailCodeVerify: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: LWRxAuthManagerEmailCodeVerify.RequestParams) -> LWPacketEmailVerificationGet {
        return Packet(observer: observer, params: params)
    }
}

extension LWPacketEmailVerificationGet {
    convenience init(observer: Any, params: LWRxAuthManagerEmailCodeVerify.RequestParams) {
        self.init()
        self.observer = observer
        self.email = params.email
        self.code = params.code
        self.accessToken = params.accessToken
    }
}
