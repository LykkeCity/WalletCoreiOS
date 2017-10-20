//
//  LWRxAuthManagerEmailWalletAddress.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class LWRxAuthManagerEmailWalletAddress: LWRxAuthManagerBase<LWPacketEmailPrivateWalletAddress> {
    
    public func requestSendEmail(forWallet wallet: LWPrivateWalletModel) -> Observable<ApiResult<Void>> {
        return Observable.create{observer in
            let pack = LWPacketEmailPrivateWalletAddress(observer: observer, wallet: wallet)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketEmailPrivateWalletAddress) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<Void>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketEmailPrivateWalletAddress) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<Void>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketEmailPrivateWalletAddress) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<Void>> else {return}
        observer.onNext(.success(withData: Void()))
        observer.onCompleted()
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == ApiResult<Void> {
    public func filterSuccess() -> Driver<Void> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Driver<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketEmailPrivateWalletAddress {
    convenience init(observer: Any, wallet: LWPrivateWalletModel) {
        self.init()
        
        self.name = wallet.name
        self.address = wallet.address
        self.observer = observer
    }
}
