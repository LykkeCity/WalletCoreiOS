//
//  LWRxAuthManagerRegistration.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/21/17.
//
//

import Foundation
import RxSwift


public class LWRxAuthManagerRegistration : LWRxAuthManagerBase<LWPacketRegistration> {
    
    public func requestRegistration(withData data: LWRegistrationData) -> Observable<ApiResult<LWPacketRegistration>> {
        return Observable.create{observer in
            let pack = LWPacketRegistration(observer: observer, data: data)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketRegistration) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketRegistration>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketRegistration) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketRegistration>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketRegistration) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketRegistration>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketRegistration> {
    public func filterSuccess() -> Observable<LWPacketRegistration> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketRegistration {
    convenience init(observer: Any, data: LWRegistrationData) {
        self.init()
        
        self.registrationData = data
        self.observer = observer
    }
}

