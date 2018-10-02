//
//  LWRxAuthManagerPhoneCodeSend.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 24.09.18.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerPhoneCodeSend: NSObject {
    
    public typealias Packet = LWPacketRequestVerificationCode
    public typealias Result = ApiResult<LWPacketRequestVerificationCode>
    public typealias ResultType = LWPacketRequestVerificationCode
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

extension LWRxAuthManagerPhoneCodeSend: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any) -> LWPacketRequestVerificationCode {
        return Packet(observer: observer)
    }
}

extension LWPacketRequestVerificationCode {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}
