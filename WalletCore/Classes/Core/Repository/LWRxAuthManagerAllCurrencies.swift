//
//  LWRxAuthManagerAllCurrencies.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/28/17.
//
//


import Foundation
import RxSwift

public class LWRxAuthManagerAllCurrencies:  LWRxAuthManagerBase<LWPacketAllAssets> {
    
    public func getAllAssets() -> Observable<ApiResult<LWPacketAllAssets>> {
        return Observable.create{observer in
            let pack = LWPacketAllAssets(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketAllAssets) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketAllAssets>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketAllAssets) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketAllAssets>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketAllAssets) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketAllAssets>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketAllAssets> {
    public func filterSuccess() -> Observable<LWPacketAllAssets> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketAllAssets {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}



