//
//  LWRxAuthManagerEmailVerificationPin.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/21/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerEmailVerificationPin: NSObject{
    
    public typealias Packet = LWPacketEmailVerificationGet
    public typealias Result = ApiResult<LWPacketEmailVerificationGet>
    public typealias ResultType = LWPacketEmailVerificationGet
    public typealias RequestParams = (email:String, pin:String)
    
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

extension LWRxAuthManagerEmailVerificationPin: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: (email: String, pin: String)) -> LWPacketEmailVerificationGet {
        return Packet(observer: observer, email: params.email, pin: params.pin)
    }
}

extension LWPacketEmailVerificationGet {
    convenience init(observer: Any, email: String, pin: String) {
        self.init()
        
        self.email = email
        self.code = pin
        self.observer = observer
    }
}

