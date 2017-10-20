//
//  LWRxAuthManagerCountryCodes.swift
//  Pods
//
//  Created by Georgi Stanev on 8/21/17.
//
//

import Foundation
import Foundation
import RxSwift

public class LWRxAuthManagerCountryCodes: LWRxAuthManagerBase<LWPacketCountryCodes> {
    
    public func requestCountryCodes() -> Observable<ApiResultList<LWCountryModel>> {
        return Observable.create{observer in
            let pack = LWPacketCountryCodes(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketCountryCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWCountryModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketCountryCodes) {
        guard let observer = pack.observer as? AnyObserver<ApiResultList<LWCountryModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketCountryCodes) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWCountryModel>> else {return}
        
        observer.onNext(.success(withData: packet.countries.map{$0 as! LWCountryModel}))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResultList<LWCountryModel> {
    public func filterSuccess() -> Observable<[LWCountryModel]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

