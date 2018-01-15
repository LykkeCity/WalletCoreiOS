//
//  LWRxAuthManagerPushNotificationsSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/29/17.
//
//


import Foundation
import RxSwift

public class LWRxAuthManagerPushNotificationsSet:  NSObject{
    
    public typealias Packet = LWPacketPushSettingsSet
    public typealias Result = ApiResult<LWPacketPushSettingsSet>
    public typealias RequestParams = (Bool)
    
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

extension LWRxAuthManagerPushNotificationsSet: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: (Bool)) -> LWPacketPushSettingsSet {
        return Packet(observer: observer, on: params)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPushSettingsSet> {
    public func filterSuccess() -> Observable<LWPacketPushSettingsSet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketPushSettingsSet {
    convenience init(observer: Any, on: Bool) {
        self.init()
        self.enabled = on
        self.observer = observer
    }
}

