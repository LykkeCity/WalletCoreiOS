//
//  LWRxAuthManagerApplicationInfo.swift
//  WalletCore
//
//  Created by Ivan Stefanovic on 1/25/18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerApplicationInfo:  NSObject{
    
    public typealias Packet = LWPacketApplicationInfo
    public typealias Result = ApiResult<LWPacketApplicationInfo>
    public typealias ResultType = LWPacketApplicationInfo
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

extension LWRxAuthManagerApplicationInfo: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketApplicationInfo {
        return Packet(observer: observer)
    }
}

extension LWPacketApplicationInfo {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}
