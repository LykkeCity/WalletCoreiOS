//
//  LWRxAuthManagerOffchainFinalizetransfer.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerOffchainFinalizetransfer : LWRxAuthManagerBase<LWPacketOffchainFinalizetransfer> {
    
    public func request(withData data: LWPacketOffchainFinalizetransfer.Body) -> Observable<ApiResult<LWModelOffchainResult>> {
        return Observable.create{observer in
            let packet = LWPacketOffchainFinalizetransfer(body: data, observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketOffchainFinalizetransfer) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketOffchainFinalizetransfer) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        
        if let model = packet.model {
            observer.onNext(.success(withData: model))
        }
        
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketOffchainFinalizetransfer) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}


