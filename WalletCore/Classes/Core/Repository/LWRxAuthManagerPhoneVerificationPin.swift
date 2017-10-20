//
//  LWRxAuthManagerPhoneVerificationPin.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//


import Foundation
import RxSwift

public class LWRxAuthManagerPhoneVerificationPin:  LWRxAuthManagerBase<LWPacketPhoneVerificationGet> {
    
    public func validatePinCode(withData phone: String, pin: String) -> Observable<ApiResult<LWPacketPhoneVerificationGet>> {
        return Observable.create{observer in
            let pack = LWPacketPhoneVerificationGet(observer: observer, phone: phone, pin: pin)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketPhoneVerificationGet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPhoneVerificationGet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketPhoneVerificationGet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketPhoneVerificationGet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketPhoneVerificationGet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPhoneVerificationGet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPhoneVerificationGet> {
    public func filterSuccess() -> Observable<LWPacketPhoneVerificationGet> {
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

extension LWPacketPhoneVerificationGet {
    convenience init(observer: Any, phone: String, pin: String) {
        self.init()
        
        self.phone = phone
        self.code = pin
        self.observer = observer
    }
}

