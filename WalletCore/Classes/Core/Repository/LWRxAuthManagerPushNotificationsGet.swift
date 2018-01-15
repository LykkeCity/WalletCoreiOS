//
//  LWRxAuthManagerPushNotificationsGet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/29/17.
//
//

import Foundation
import RxSwift


public class LWRxAuthManagerPushNotificationsGet:  NSObject{
    
    public typealias Packet = LWPacketPushSettingsGet
    public typealias Result = ApiResult<LWPacketPushSettingsGet>
    public typealias ResultType = LWPacketPushSettingsGet
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

extension LWRxAuthManagerPushNotificationsGet: AuthManagerProtocol{
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWPacketPushSettingsGet {
        return Packet(observer: observer)
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPushSettingsGet> {
    public func filterSuccess() -> Observable<LWPacketPushSettingsGet> {
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

extension LWPacketPushSettingsGet {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}

