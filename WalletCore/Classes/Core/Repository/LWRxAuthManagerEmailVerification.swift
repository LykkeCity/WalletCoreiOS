//
//  LWRxAuthManagerEmailVerification.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/18/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerEmailVerification: LWRxAuthManagerBase<LWPacketEmailVerificationSet> {

    public func verifyEmail(withData data: String) -> Observable<ApiResult<LWPacketEmailVerificationSet>> {
        return Observable.create{observer in
            let pack = LWPacketEmailVerificationSet(observer: observer, data: data)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketEmailVerificationSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketEmailVerificationSet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketEmailVerificationSet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketEmailVerificationSet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketEmailVerificationSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketEmailVerificationSet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketEmailVerificationSet> {
    public func filterSuccess() -> Observable<LWPacketEmailVerificationSet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketEmailVerificationSet {
    convenience init(observer: Any, data: String) {
        self.init()
        
        self.email = data
        self.observer = observer
    }
}

