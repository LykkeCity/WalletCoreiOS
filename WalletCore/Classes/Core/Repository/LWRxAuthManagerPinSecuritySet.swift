//
//  LWRxAuthManagerPinSecuritySet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/21/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPinSecuritySet: LWRxAuthManagerBase<LWPacketPinSecuritySet> {

    public func validatePin(withData data: String) -> Observable<ApiResult<LWPacketPinSecuritySet>> {
        return Observable.create{observer in
            let pack = LWPacketPinSecuritySet(observer: observer, data: data)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketPinSecuritySet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPinSecuritySet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketPinSecuritySet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketPinSecuritySet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketPinSecuritySet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPinSecuritySet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
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

