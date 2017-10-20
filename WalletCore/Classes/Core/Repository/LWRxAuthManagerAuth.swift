//
//  LWRxAuthenticationManagerAuth.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/17/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerAuth: LWRxAuthManagerBase<LWPacketAuthentication> {
    
    public func requestLogin(withData data: LWAuthenticationData) -> Observable<ApiResult<LWPacketAuthentication>> {
        return Observable.create{observer in
            let pack = LWPacketAuthentication(observer: observer, data: data)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketAuthentication) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketAuthentication>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketAuthentication) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketAuthentication>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketAuthentication) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketAuthentication>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketAuthentication> {
    public func filterSuccess() -> Observable<LWPacketAuthentication> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }

    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketAuthentication {
    convenience init(observer: Any, data: LWAuthenticationData) {
        self.init()
        
        self.authenticationData = data
        self.observer = observer
    }
}

