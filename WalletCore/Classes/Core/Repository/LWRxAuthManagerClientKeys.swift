//
//  LWRxAuthManagerClientKeys.swift
//  Pods
//
//  Created by Nikola Bardarov on 9/4/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerClientKeys: LWRxAuthManagerBase<LWPacketClientKeys> {
    
    public func setClientKeys(withPubKey pubKey: String, encodedPrivateKey: String) -> Observable<ApiResult<LWPacketClientKeys>> {
        return Observable.create{observer in
            let pack = LWPacketClientKeys(observer: observer, pubKey: pubKey, encodedPrivateKey: encodedPrivateKey)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketClientKeys) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketClientKeys>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketClientKeys) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketClientKeys>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketClientKeys) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketClientKeys>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketClientKeys> {
    public func filterSuccess() -> Observable<LWPacketClientKeys> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketClientKeys {
    convenience init(observer: Any, pubKey: String, encodedPrivateKey: String) {
        self.init()
        
        self.pubKey = pubKey
        self.encodedPrivateKey = encodedPrivateKey
        self.observer = observer
    }
}

