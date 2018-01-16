//
//  LWOffchainTransactionsManager+Rx.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/12/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public extension Reactive where Base : LWOffchainTransactionsManager {
    func sendSwapRequest(forAsset asset: LWAssetModel, pair: LWAssetPairModel, volume: Decimal) -> Observable<ApiResult<[AnyHashable: Any]>> {
        let manager = self.base
        
        return Observable.create{[weak manager] observer in
            manager?.sendSwapRequest(forAsset: asset.identity, pair: pair.identity, volume: volume as NSNumber) {data in
                guard let data = data else {
                    observer.onCompleted()
                    return
                }
                
                if let errorData = data["Error"] as? [AnyHashable: Any] {
                    observer.onNext(.error(withData:errorData))
                    observer.onCompleted()
                    return
                }
                
                observer.onNext(.success(withData: data))
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func requestCashOut(amount: Decimal, assetId: String, multiSig: String) -> Observable<ApiResult<[AnyHashable: Any]>> {
        let manager = self.base
        
        return Observable.create{[weak manager] observer in
            manager?.requestCashOut(amount as NSDecimalNumber, assetId: assetId, multiSig: multiSig) {data in
                guard let data = data else {
                    observer.onCompleted()
                    return
                }
                
                if let errorData = data["Error"] as? [AnyHashable: Any] {
                    observer.onNext(.error(withData:errorData))
                    observer.onCompleted()
                    return
                }
                
                observer.onNext(.success(withData: data))
                observer.onCompleted()
            }
            
            return Disposables.create {}
            }
            .startWith(.loading)
            .shareReplay(1)
    }
}


public extension ObservableType where Self.E == ApiResult<[AnyHashable: Any]> {
    public func filterSuccess() -> Observable<[AnyHashable: Any]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable<[AnyHashable: Any]> {
        return map{$0.getError()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
