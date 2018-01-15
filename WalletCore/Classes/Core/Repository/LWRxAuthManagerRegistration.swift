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

public extension ObservableType where Self.E == ApiResult<LWPacketRegistration> {
    public func filterSuccess() -> Observable<LWPacketRegistration> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketRegistration {
    convenience init(observer: Any, data: LWRegistrationData) {
        self.init()
        
        self.registrationData = data
        self.observer = observer
    }
}

