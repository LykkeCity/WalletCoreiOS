//
//  LWRxAuthManagerOffchainProcessChannel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerOffchainProcessChannel : LWRxAuthManagerBase<LWPacketOffchainProcessChannel> {
    
    public func request(withData data: LWPacketOffchainProcessChannel.Body) -> Observable<ApiResult<LWModelOffchainResult>> {
        return Observable.create{observer in
            let packet = LWPacketOffchainProcessChannel(body: data, observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketOffchainProcessChannel) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketOffchainProcessChannel) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        
        if let model = packet.model {
            observer.onNext(.success(withData: model))
        }
        
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketOffchainProcessChannel) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}
