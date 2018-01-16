//
//  LWRxAuthManagerGetClientCodes.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/21/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerGetClientCodes:  NSObject{
    
    public typealias Packet = LWPacketGetClientCodes
    public typealias Result = ApiResult<LWPacketGetClientCodes>
    public typealias ResultType = LWPacketGetClientCodes
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

extension LWRxAuthManagerGetClientCodes: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketGetClientCodes {
        return Packet(observer: observer)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketGetClientCodes> {
    public func filterSuccess() -> Observable<LWPacketGetClientCodes> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func filterError() -> Observable<[AnyHashable: Any]> {
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketGetClientCodes {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}

