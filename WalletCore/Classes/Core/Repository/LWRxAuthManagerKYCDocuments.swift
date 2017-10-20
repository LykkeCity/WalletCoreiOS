//
//  LWRxAuthManagerKYCDocuments.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/20/17.
//  Copyright © 2017 Lykke. All rights reserved.
//
import Foundation
import RxSwift

public class LWRxAuthManagerKYCDocuments : LWRxAuthManagerBase<LWPacketKYCDocuments> {
    
    public func request(assetId: String) -> Observable<ApiResult<LWKYCDocumentsModel>> {
        return Observable.create{observer in
            let packet = LWPacketKYCDocuments(observer: observer)
            GDXNet.instance().send(packet, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketKYCDocuments) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWKYCDocumentsModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketKYCDocuments) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWKYCDocumentsModel>> else {return}
        observer.onNext(.success(withData: packet.documentsStatuses))
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketKYCDocuments) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketKYCDocuments>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWKYCDocumentsModel> {
    public func filterSuccess() -> Observable<LWKYCDocumentsModel> {
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
