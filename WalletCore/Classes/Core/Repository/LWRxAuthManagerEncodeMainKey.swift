//
//  LWRxAuthManagerEncodeMainKey.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/23/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerEncodeMainKey : LWRxAuthManagerBase<LWPacketEncodedMainKey> {
    
    public func requestEncodeMainKey(accessToken: String) -> Observable<ApiResult<LWPacketEncodedMainKey>> {
        return Observable.create{observer in
            let packet = LWPacketEncodedMainKey(observer: observer, accessToken: accessToken)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketEncodedMainKey) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketEncodedMainKey>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketEncodedMainKey) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketEncodedMainKey>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketEncodedMainKey) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketEncodedMainKey>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketEncodedMainKey) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketEncodedMainKey>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketEncodedMainKey> {
    public func filterSuccess() -> Observable<LWPacketEncodedMainKey> {
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

extension LWPacketEncodedMainKey {
    convenience init(observer: Any, accessToken: String) {
        self.init()
        self.observer = observer
        self.accessToken = accessToken
    }
}
