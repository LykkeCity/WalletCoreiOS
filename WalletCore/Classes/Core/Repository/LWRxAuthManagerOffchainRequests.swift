//
//  LWRxAuthManagerOffchainRequests.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerOffchainRequests : LWRxAuthManagerBase<LWPacketOffchainRequests> {
    
    public func request(forAsset assetId: String) -> Observable<ApiResultList<LWModelOffchainRequest>> {
        return Observable.create{observer in
            let packet = LWPacketOffchainRequests(observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketOffchainRequests) {
        guard let observer = pack.observer as? AnyObserver<ApiResultList<LWModelOffchainRequest>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketOffchainRequests) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWModelOffchainRequest>> else {return}
        observer.onNext(.success(withData: packet.models))
    
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketOffchainRequests) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWModelOffchainRequest>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResultList<LWModelOffchainRequest> {
    public func filterSuccess() -> Observable<[LWModelOffchainRequest]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
