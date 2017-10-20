//
//  LWRxAuthManagerPostClientCodes.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/22/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerPostClientCodes: LWRxAuthManagerBase<LWPacketPostClientCodes> {
    
    public func requestPostClientCodes(codeSms: String) -> Observable<ApiResult<LWPacketPostClientCodes>> {
        return Observable.create{observer in
            let packet = LWPacketPostClientCodes(observer: observer, codeSms: codeSms)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketPostClientCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPostClientCodes>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketPostClientCodes) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketPostClientCodes>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketPostClientCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPostClientCodes>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketPostClientCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPostClientCodes>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPostClientCodes> {
    public func filterSuccess() -> Observable<LWPacketPostClientCodes> {
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

extension LWPacketPostClientCodes {
    convenience init(observer: Any, codeSms: String) {
        self.init()
        self.observer = observer
        self.codeSms = codeSms
    }
}


