//
//  LWRxAuthManagerSettingSignOrder.swift
//  WalletCore
//
//  Created by Ivan Stefanovic on 1/29/18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerSettingSignOrder:  NSObject{
    
    public typealias Packet = LWPacketSettingSignOrder
    public typealias Result = ApiResult<LWPacketSettingSignOrder>
    public typealias ResultType = LWPacketSettingSignOrder
    public typealias RequestParams = Bool
    
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

extension LWRxAuthManagerSettingSignOrder: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: Bool) -> LWPacketSettingSignOrder {
        return Packet(observer: observer, shouldSign: params)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketSettingSignOrder> {
    public func filterSuccess() -> Observable<LWPacketSettingSignOrder> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketSettingSignOrder {
    convenience init(observer: Any, shouldSign: Bool) {
        self.init()
        self.observer = observer
        self.shouldSignOrder = shouldSign
    }
}
