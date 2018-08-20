//
//  LWRxAuthManagerKYCStatusGet.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 30/07/18.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerKYCStatusGet : NSObject{
    
    public typealias Packet = LWPacketKYCStatusGet
    public typealias Result = ApiResult<LWPacketKYCStatusGet>
    public typealias ResultType = LWPacketKYCStatusGet
    public typealias RequestParams = ()
    
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

extension LWRxAuthManagerKYCStatusGet: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: ()) -> LWPacketKYCStatusGet {
        return Packet(observer: observer)
    }
}

extension LWPacketKYCStatusGet {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}
