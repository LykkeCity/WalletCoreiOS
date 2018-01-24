//
//  LWRxAuthManagerBaseAssets.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerBaseAssets:  NSObject{
    
    public typealias Packet = LWPacketBaseAssets
    public typealias Result = ApiResult<LWPacketBaseAssets>
    public typealias ResultType = LWPacketBaseAssets
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

extension LWRxAuthManagerBaseAssets: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: ()) -> LWPacketBaseAssets {
        return Packet(observer: observer)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketBaseAssets> {
    public func filterSuccess() -> Observable<LWPacketBaseAssets> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketBaseAssets {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}

