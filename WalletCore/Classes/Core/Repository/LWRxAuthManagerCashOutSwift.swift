//
//  LWRxAuthManagerCashOutSwift.swift
//  WalletCore
//
//  Created by Nacho Nachev on 2.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift

public class LWRxAuthManagerCashOutSwift: LWRxAuthManagerBase<LWPacketCashOutSwift> {

    public func request(withData data: LWPacketCashOutSwift.Body) -> Observable<ApiResult<Void>> {
        return Observable.create { observer in
            let packet = LWPacketCashOutSwift(body: data, observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketCashOutSwift) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<Void>> else {return}
        
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketCashOutSwift) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<Void>> else {return}
        
        observer.onNext(.success(withData: Void()))
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketCashOutSwift) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketCashOutSwift>> else {return}
        
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
    
}

public extension ObservableType where Self.E == ApiResult<Void> {
    public func filterSuccess() -> Observable<Void> {
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
