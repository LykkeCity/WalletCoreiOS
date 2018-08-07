//
//  LWRxAuthManagerGetOwnershipMsg.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 30.07.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerOwnershipMessage: NSObject {
    
    public typealias Packet = LWPrivateKeyOwnershipMessage
    public typealias Result = ApiResult<LWPrivateKeyOwnershipMessage>
    public typealias ResultType = LWPrivateKeyOwnershipMessage
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


extension LWRxAuthManagerOwnershipMessage: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: RequestParams) -> LWPrivateKeyOwnershipMessage {
        return Packet(observer: observer, email: params.email, signature: params.signature)
    }
}


extension LWPrivateKeyOwnershipMessage {

    convenience init(observer: Any, email: String, signature: String) {
        self.init()
        self.email = email
        if !signature.isEmpty {
            self.signature = signature
        }
        self.observer = observer
    }

}
