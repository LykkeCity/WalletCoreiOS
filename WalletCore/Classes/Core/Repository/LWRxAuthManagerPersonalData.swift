//
//  LWRxAuthManagerPersonalData.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/23/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerPersonalData: LWRxAuthManagerBase<LWPacketPersonalData> {

    public func getPersonalData() -> Observable<ApiResult<LWPacketPersonalData>> {
        return Observable.create{observer in
            let pack = LWPacketPersonalData(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketPersonalData) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPersonalData>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketPersonalData) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketPersonalData>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketPersonalData) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketPersonalData>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketPersonalData> {
    public func filterSuccess() -> Observable<LWPacketPersonalData> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketPersonalData {
    convenience init(observer: Any) {
        self.init()
        
        self.observer = observer
    }
}


