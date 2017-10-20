//
//  LWRxAuthManagerPinSecurityGet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/31/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPinSecurityGet: LWRxAuthManagerBase<LWPacketPinSecurityGet> {
    
    public func validatePin(withData data: String) -> Observable<ApiResult<LWPacketPinSecurityGet>> {
        return Observable.create{observer in
            let pack = LWPacketPinSecurityGet(observer: observer, data: data)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketPinSecurityGet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPinSecurityGet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketPinSecurityGet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketPinSecurityGet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketPinSecurityGet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPinSecurityGet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
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

