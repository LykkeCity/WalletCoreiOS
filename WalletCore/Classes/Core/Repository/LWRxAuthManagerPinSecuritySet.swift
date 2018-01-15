//
//  LWRxAuthManagerPinSecuritySet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/21/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPinSecuritySet: NSObject{
    
    public typealias Packet = LWPacketPinSecuritySet
    public typealias Result = ApiResult<LWPacketPinSecuritySet>
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

extension LWRxAuthManagerPinSecuritySet: AuthManagerProtocol{

    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketPinSecuritySet {
        return Packet(observer: observer, data: params)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPinSecuritySet> {
    public func filterSuccess() -> Observable<LWPacketPinSecuritySet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketPinSecuritySet {
    convenience init(observer: Any, data: String) {
        self.init()
        
        self.pin = data
        self.observer = observer
    }
}

