//
//  LWRxAuthManagerPushNotificationsSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/29/17.
//
//


import Foundation
import RxSwift

public class LWRxAuthManagerPushNotificationsSet:  LWRxAuthManagerBase<LWPacketPushSettingsSet> {
    
    public func setPushNotifications(isOn on: Bool) -> Observable<ApiResult<LWPacketPushSettingsSet>> {
        return Observable.create{observer in
            let pack = LWPacketPushSettingsSet(observer: observer, on: on)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketPushSettingsSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPushSettingsSet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketPushSettingsSet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketPushSettingsSet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketPushSettingsSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPushSettingsSet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
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

