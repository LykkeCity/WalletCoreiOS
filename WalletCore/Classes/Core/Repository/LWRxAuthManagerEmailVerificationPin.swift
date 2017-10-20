//
//  LWRxAuthManagerEmailVerificationPin.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/21/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerEmailVerificationPin: LWRxAuthManagerBase<LWPacketEmailVerificationGet> {
    
    public func validatePinCode(withData email: String, pin: String) -> Observable<ApiResult<LWPacketEmailVerificationGet>> {
        return Observable.create{observer in
            let pack = LWPacketEmailVerificationGet(observer: observer, email: email, pin: pin)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketEmailVerificationGet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketEmailVerificationGet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketEmailVerificationGet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketEmailVerificationGet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketEmailVerificationGet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketEmailVerificationGet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketEmailVerificationGet> {
    public func filterSuccess() -> Observable<LWPacketEmailVerificationGet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketEmailVerificationGet {
    convenience init(observer: Any, email: String, pin: String) {
        self.init()
        
        self.email = email
        self.code = pin
        self.observer = observer
    }
}

