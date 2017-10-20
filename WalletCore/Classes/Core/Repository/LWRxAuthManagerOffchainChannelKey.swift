//
//  LWRxAuthManagerOffchainChannelKey.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerOffchainChannelKey : LWRxAuthManagerBase<LWPacketOffchainChannelKey> {
    
    public func request(forAsset assetId: String) -> Observable<ApiResult<LWModelOffchainChannelKey>> {
        return Observable.create{observer in
            let packet = LWPacketOffchainChannelKey(assetId: assetId, observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketOffchainChannelKey) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWModelOffchainChannelKey>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketOffchainChannelKey) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainChannelKey>> else {return}
        
        if let model = packet.model {
            observer.onNext(.success(withData: model))
        }
        
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketOffchainChannelKey) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainChannelKey>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWModelOffchainChannelKey> {
    public func filterSuccess() -> Observable<LWModelOffchainChannelKey> {
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
