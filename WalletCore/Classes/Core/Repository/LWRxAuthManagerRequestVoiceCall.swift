//
//  LWRxAuthManagerRequestVoiceCall.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 10.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerRequestVoiceCall: NSObject {
    
    public typealias Packet = LWPacketVoiceCall
    public typealias Result = ApiResult<LWPacketVoiceCall>
    public typealias ResultType = LWPacketVoiceCall
    public typealias RequestParams = (phone: String, email: String)
    
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


extension LWRxAuthManagerRequestVoiceCall: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: RequestParams) -> LWPacketVoiceCall {
        return Packet(observer: observer, phone: params.phone, email: params.email)
    }
}


extension LWPacketVoiceCall {
    
    convenience init(observer: Any, phone: String, email: String) {
        self.init()
        self.observer = observer

        self.phone = phone
        self.email = email
    }
    
}
