//
//  LWRxAuthManagerHomeCountry.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//

import Foundation
import Foundation
import RxSwift

public class LWRxAuthManagerHomeCountry: NSObject{
    
    public typealias Packet = LWPacketCountryCodes
    public typealias Result = ApiResult<LWPacketCountryCodes>
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

extension LWRxAuthManagerHomeCountry: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketCountryCodes {
        return Packet(observer: observer)
    }
}


public extension ObservableType where Self.E == ApiResult<LWPacketCountryCodes> {
    public func filterSuccess() -> Observable<LWPacketCountryCodes> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}


