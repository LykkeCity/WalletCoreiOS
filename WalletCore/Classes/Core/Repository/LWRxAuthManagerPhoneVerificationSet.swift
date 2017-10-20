//
//  LWRxAuthManagerPhoneVerificationSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPhoneVerificationSet: LWRxAuthManagerBase<LWPacketPhoneVerificationSet>  {
    
    public func setPhoneNumber(withPhone phone: String) -> Observable<ApiResult<LWPacketPhoneVerificationSet>> {
        return Observable.create{observer in
            let pack = LWPacketPhoneVerificationSet(observer: observer, data: phone)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketPhoneVerificationSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPhoneVerificationSet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketPhoneVerificationSet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketPhoneVerificationSet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketPhoneVerificationSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPhoneVerificationSet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPhoneVerificationSet> {
    public func filterSuccess() -> Observable<LWPacketPhoneVerificationSet> {
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

extension LWPacketPhoneVerificationSet {
    convenience init(observer: Any, data: String) {
        self.init()
        
        self.phone = data
        self.observer = observer
    }
}


