//
//  LWRxAuthManagerPinSecurityGet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/31/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPinSecurityGet: NSObject{
    public typealias Packet = LWPacketPinSecurityGet
    public typealias Result = ApiResult<LWPacketPinSecurityGet>
    public typealias RequestParams = (String)
    
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
    
extension LWRxAuthManagerPinSecurityGet: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketPinSecurityGet {
        return Packet(observer: observer, data: params)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPinSecurityGet> {
    public func filterSuccess() -> Observable<LWPacketPinSecurityGet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketPinSecurityGet {
    convenience init(observer: Any, data: String) {
        self.init()
        
        self.pin = data
        self.observer = observer
    }
}

