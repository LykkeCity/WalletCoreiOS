//
//  LWRxAuthManagerPhoneVerificationPin.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//


import Foundation
import RxSwift

public class LWRxAuthManagerPhoneVerificationPin:  NSObject{
    
    public typealias Packet = LWPacketPhoneVerificationGet
    public typealias Result = ApiResult<LWPacketPhoneVerificationGet>
    public typealias ResultType = LWPacketPhoneVerificationGet
    public typealias RequestParams = (phone: String, pin: String)
    
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

extension LWRxAuthManagerPhoneVerificationPin: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (phone: String, pin: String)) -> LWPacketPhoneVerificationGet {
        return Packet(observer: observer, phone: params.phone, pin: params.pin)
    }
}

extension LWPacketPhoneVerificationGet {
    convenience init(observer: Any, phone: String, pin: String) {
        self.init()
        
        self.phone = phone
        self.code = pin
        self.observer = observer
    }
}

