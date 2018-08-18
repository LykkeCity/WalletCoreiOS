//
//  LWRxAuthManagerChangePinAndPassword.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 15.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerChangePinAndPassword: NSObject {
    
    public typealias Packet = LWPacketChangePINAndPassword
    public typealias Result = ApiResult<LWPacketChangePINAndPassword>
    public typealias ResultType = LWPacketChangePINAndPassword
    public typealias RequestParams = (LWRecoveryPasswordModel)
    
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


extension LWRxAuthManagerChangePinAndPassword: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: RequestParams) -> LWPacketChangePINAndPassword {
        return Packet(observer: observer, recModel: params)
    }
}


extension LWPacketChangePINAndPassword {
    
    convenience init(observer: Any, recModel: LWRecoveryPasswordModel) {
        self.init()
        self.recModel = recModel
        
        self.observer = observer
    }
    
}
