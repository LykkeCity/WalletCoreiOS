//
//  LWRxAuthManagerTransactions.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/10/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerTransactions: LWRxAuthManagerBase<LWPacketTransactions> {
    
    public func requestTransactions(forAssetId assetId: String? = nil) -> Observable<ApiResult<LWTransactionsModel>> {
        return Observable.create{observer in
            
            let pack = LWPacketTransactions(observer: observer, assetId: assetId)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketTransactions) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWTransactionsModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketTransactions) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWTransactionsModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketTransactions) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWTransactionsModel>> else {return}
        observer.onNext(.success(withData: packet.model))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWTransactionsModel> {
    public func filterSuccess() -> Observable<LWTransactionsModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketTransactions {
    convenience init(observer: Any, assetId: String?) {
        self.init()
        
        if let assetId = assetId {
            self.assetId = NSString(string: assetId)
        }
        
        self.observer = observer
    }
}
