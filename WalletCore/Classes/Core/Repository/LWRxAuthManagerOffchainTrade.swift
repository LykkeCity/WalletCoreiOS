//
//  LWRxAuthManagerOffchainTrade.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerOffchainTrade : LWRxAuthManagerBase<LWPacketOffchainTrade> {
    
    public func request(withData data: LWPacketOffchainTrade.Body) -> Observable<ApiResult<LWModelOffchainResult>> {
        return Observable.create{observer in
            let packet = LWPacketOffchainTrade(body: data, observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketOffchainTrade) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketOffchainTrade) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        
        if let model = packet.model {
            observer.onNext(.success(withData: model))
        }
        
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketOffchainTrade) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWModelOffchainResult>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == [ApiResult<LWModelOffchainResult>] {
    public func filterSuccess() -> Observable<[LWModelOffchainResult]> {
        return filter{ $0.allSuccessful() }
               .map{ $0.filterSuccess() }
    }
}

extension Array where Element == ApiResult<LWModelOffchainResult> {
    func allSuccessful() -> Bool {
        return first{!$0.isSuccess} == nil
    }
    
    func filterSuccess() -> [LWModelOffchainResult] {
        return map{ $0.getSuccess() }
               .filter{ $0 != nil }
               .map{ $0! }
    }
}

public extension ObservableType where Self.E == ApiResult<LWModelOffchainResult> {
    public func filterSuccess() -> Observable<LWModelOffchainResult> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

