//
//  LWRxAuthManagerOffchainCashOutSwift.swift
//  WalletCore
//
//  Created by Nacho Nachev on 03/11/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerOffchainCashOutSwift: LWRxAuthManagerBase<LWPacketOffchainCashOutSwift> {

    public func request(withData data: LWPacketOffchainCashOutSwift.Body) -> Observable<ApiResult<LWModelOffchainResult>> {
        return Observable.create{observer in
            let packet = LWPacketOffchainCashOutSwift(body: data, observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketOffchainCashOutSwift) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketOffchainCashOutSwift) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        
        if let model = packet.model {
            observer.onNext(.success(withData: model))
        }
        
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketOffchainCashOutSwift) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }

}
