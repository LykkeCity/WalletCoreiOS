//
//  LWRxAuthManagerRecoverySmsConfirmation.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 15.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerRecoverySmsConfirmation: NSObject {
    
    public typealias Packet = LWPacketRecoverySMSConfirmation
    public typealias Result = ApiResult<LWPacketRecoverySMSConfirmation>
    public typealias ResultType = LWPacketRecoverySMSConfirmation
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


extension LWRxAuthManagerRecoverySmsConfirmation: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: RequestParams) -> LWPacketRecoverySMSConfirmation {
        return Packet(observer: observer, recModel: params)
    }
}


extension LWPacketRecoverySMSConfirmation {
    
    convenience init(observer: Any, recModel: LWRecoveryPasswordModel) {
        self.init()
        self.recModel = recModel
        
        self.observer = observer
    }
    
}
