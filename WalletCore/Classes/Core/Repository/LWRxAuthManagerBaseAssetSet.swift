//
//  LWRxAuthManagerBaseAssetSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/29/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerBaseAssetSet:  LWRxAuthManagerBase<LWPacketBaseAssetSet> {
    
    public func setBaseAsset(withIdentity identity:String) -> Observable<ApiResult<LWPacketBaseAssetSet>> {
        return Observable.create{observer in
            let pack = LWPacketBaseAssetSet(observer: observer, identity: identity)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketBaseAssetSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketBaseAssetSet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketBaseAssetSet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketBaseAssetSet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketBaseAssetSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketBaseAssetSet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketBaseAssetSet> {
    public func filterSuccess() -> Observable<LWPacketBaseAssetSet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketBaseAssetSet {
    convenience init(observer: Any, identity: String) {
        self.init()
        self.observer = observer
        self.identity = identity
    }
}

