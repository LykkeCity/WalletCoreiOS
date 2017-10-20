//
//  LWRxAuthManagerAccountExist.swift
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/28/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAccountExist : LWRxAuthManagerBase<LWPacketAccountExist> {
    
    public func requestAccountExist(email: String) -> Observable<ApiResult<LWPacketAccountExist>> {
        return Observable.create{observer in
            
            let packet = LWPacketAccountExist(observer: observer, email: email)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketAccountExist) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketAccountExist>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketAccountExist) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketAccountExist>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketAccountExist> {
    public func filterSuccess() -> Observable<LWPacketAccountExist> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketAccountExist {
    convenience init(observer: Any, email: String) {
        self.init()
        self.observer = observer
        self.email = email
    }
}
