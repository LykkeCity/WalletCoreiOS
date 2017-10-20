//
//  LWRxAuthManagerSwiftCredentials.swift
//  LykkeWallet
//
//  Created by Bozidar Nikolic on 7/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerSwiftCredentials: LWRxAuthManagerBase<LWPacketSwiftCredential> {
    
    public func requestSwiftCredentials(assetId: String) -> Observable<ApiResult<LWPacketSwiftCredential>> {
        return Observable.create{observer in
            let packet = LWPacketSwiftCredential(observer: observer, assetId: assetId)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketSwiftCredential) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketSwiftCredential>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketSwiftCredential) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketSwiftCredential>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketSwiftCredential) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketSwiftCredential>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketSwiftCredential> {
    public func filterSuccess() -> Observable<LWPacketSwiftCredential> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketSwiftCredential {
    convenience init(observer: Any, assetId: String) {
        self.init()
        self.observer = observer
        self.identity = assetId
    }
}


