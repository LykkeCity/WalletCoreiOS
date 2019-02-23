//
//  LWRxAuthManagerRegistration.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/21/17.
//
//

import Foundation
import RxSwift


public class LWRxAuthManagerRegistration : NSObject{
    
    public typealias Packet = LWPacketRegistration
    public typealias Result = ApiResult<LWPacketRegistration>
    public typealias ResultType = LWPacketRegistration
    public typealias RequestParams = (LWRegistrationData)
    
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

extension LWRxAuthManagerRegistration: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (LWRegistrationData)) -> LWPacketRegistration {
        return Packet(observer: observer, data: params)
    }
}

extension LWPacketRegistration {
    convenience init(observer: Any, data: LWRegistrationData) {
        self.init()
        
        self.registrationData = data
        self.observer = observer
    }
}

