//
//  LWRxAuthManagerLykkeWallets.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerLykkeWallets: LWRxAuthManagerBase<LWPacketWallets> {
    
    public func requestLykkeWallets() -> Observable<ApiResult<LWLykkeWalletsData>> {
        return Observable.create{observer in
           
            let pack = LWPacketWallets(observer: observer)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    public func requestNonEmptyWallets() -> Observable<[LWSpotWallet]> {
        return requestLykkeWallets()
            .filterSuccess()
            .map{$0.lykkeData.wallets}
            .replaceNilWith([])
            .map{$0 as! [LWSpotWallet]}
            .map{$0.filter{$0.balance.doubleValue > 0.0}}
    }

    override func onNotAuthorized(withPacket packet: LWPacketWallets) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWLykkeWalletsData>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }

    override func onError(withData data: [AnyHashable : Any], pack: LWPacketWallets) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWLykkeWalletsData>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }

    override func onSuccess(packet: LWPacketWallets) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWLykkeWalletsData>> else {return}
        observer.onNext(.success(withData: packet.data))
        observer.onCompleted()
    }
}


public extension ObservableType where Self.E == ApiResult<LWLykkeWalletsData> {
    public func filterSuccess() -> Observable<LWLykkeWalletsData> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
