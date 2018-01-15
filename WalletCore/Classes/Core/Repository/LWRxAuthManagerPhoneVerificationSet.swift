//
//  LWRxAuthManagerPhoneVerificationSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPhoneVerificationSet: NSObject{
    
    public typealias Packet = LWPacketPhoneVerificationSet
    public typealias Result = ApiResult<LWPacketPhoneVerificationSet>
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

extension LWRxAuthManagerPhoneVerificationSet: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketPhoneVerificationSet {
        return Packet(observer: observer, data: params)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPhoneVerificationSet> {
    public func filterSuccess() -> Observable<LWPacketPhoneVerificationSet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketPhoneVerificationSet {
    convenience init(observer: Any, data: String) {
        self.init()
        
        self.phone = data
        self.observer = observer
    }
}


