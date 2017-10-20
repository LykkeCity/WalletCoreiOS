//
//  LWRxAuthManagerHomeCountry.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//

import Foundation
import Foundation
import RxSwift

public class LWRxAuthManagerHomeCountry: LWRxAuthManagerBase<LWPacketCountryCodes> {
    
    public func requestMyCountry() -> Observable<ApiResult<LWPacketCountryCodes>> {
        return Observable.create{observer in
            let pack = LWPacketCountryCodes(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketCountryCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketCountryCodes>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketCountryCodes) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketCountryCodes>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketCountryCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketCountryCodes>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
    

}


public extension ObservableType where Self.E == ApiResult<LWPacketCountryCodes> {
    public func filterSuccess() -> Observable<LWPacketCountryCodes> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}


