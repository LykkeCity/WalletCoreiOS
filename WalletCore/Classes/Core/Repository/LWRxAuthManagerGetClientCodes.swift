//
//  LWRxAuthManagerGetClientCodes.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/21/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerGetClientCodes:  LWRxAuthManagerBase<LWPacketGetClientCodes> {

    public func requestGetClientCodes() -> Observable<ApiResult<LWPacketGetClientCodes>> {
        return Observable.create{observer in
            let packet = LWPacketGetClientCodes(observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketGetClientCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGetClientCodes>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketGetClientCodes) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketGetClientCodes>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketGetClientCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGetClientCodes>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketGetClientCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGetClientCodes>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketGetClientCodes> {
    public func filterSuccess() -> Observable<LWPacketGetClientCodes> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func filterError() -> Observable<[AnyHashable: Any]> {
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketGetClientCodes {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}

