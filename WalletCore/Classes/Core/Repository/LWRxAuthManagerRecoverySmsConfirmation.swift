//
//  LWRxAuthManagerRecoverySmsConfirmation.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 7.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerRecoverySmsConfirmation: NSObject {
    
    public typealias Packet = LWPacketRecoverySMSConfirmation
    public typealias Result = ApiResult<LWPacketRecoverySMSConfirmation>
    public typealias ResultType = LWPacketRecoverySMSConfirmation
    public typealias RequestParams = (email: String, signature: String)
    
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


extension LWRxAuthManagerRecoverySmsConfirmation: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: RequestParams) -> LWPacketRecoverySMSConfirmation {
        return Packet(observer: observer, email: params.email, signature: params.signature)
    }
}


extension LWPacketRecoverySMSConfirmation {
    
    convenience init(observer: Any, email: String, signature: String) {
        self.init()
        self.recModel.email = email
        self.recModel.signature1 = signature
        
        self.observer = observer
    }
    
}
