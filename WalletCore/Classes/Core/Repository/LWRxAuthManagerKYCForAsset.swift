//
//  LWRxAuthManagerKYCForAsset.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerKYCForAsset : LWRxAuthManagerBase<LWPacketKYCForAsset> {
    
    public func request(assetId: String) -> Observable<ApiResult<LWPacketKYCForAsset>> {
        return Observable.create{observer in
            let packet = LWPacketKYCForAsset(observer: observer, assetId: assetId)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketKYCForAsset) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketKYCForAsset>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketKYCForAsset) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketKYCForAsset>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketKYCForAsset> {
    public func filterSuccess() -> Observable<LWPacketKYCForAsset> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketKYCForAsset {
    convenience init(observer: Any, assetId: String) {
        self.init()
        self.observer = observer
        self.assetId = assetId
    }
}
