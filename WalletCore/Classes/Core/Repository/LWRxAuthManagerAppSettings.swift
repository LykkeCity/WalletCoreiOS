//
//  LWRxAuthManagerAppSettings.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/28/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerAppSettings:  LWRxAuthManagerBase<LWPacketAppSettings> {
    
    public func getAppSettings() -> Observable<ApiResult<LWPacketAppSettings>> {
        return Observable.create{observer in
            let pack = LWPacketAppSettings(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketAppSettings) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketAppSettings>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketAppSettings) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketAppSettings>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketAppSettings) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketAppSettings>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketAppSettings> {
    public func filterSuccess() -> Observable<LWPacketAppSettings> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketAppSettings {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}

