//
//  LWRxAuthManagerCleintFullNameSet.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/24/17.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerCleintFullNameSet: LWRxAuthManagerBase<LWPacketClientFullNameSet>  {
    
    public func setFullName(withName fullName: String) -> Observable<ApiResult<LWPacketClientFullNameSet>> {
        return Observable.create{observer in
            let pack = LWPacketClientFullNameSet(observer: observer, data: fullName)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketClientFullNameSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketClientFullNameSet>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketClientFullNameSet) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketClientFullNameSet>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketClientFullNameSet) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketClientFullNameSet>> else {return}
        
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketClientFullNameSet> {
    public func filterSuccess() -> Observable<LWPacketClientFullNameSet> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable< [AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketClientFullNameSet {
    convenience init(observer: Any, data: String) {
        self.init()
        
        self.fullName = data
        self.observer = observer
    }
}


