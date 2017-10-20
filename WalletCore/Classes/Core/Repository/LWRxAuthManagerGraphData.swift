//
//  LWRxAuthManagerGraphData.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerGraphData: LWRxAuthManagerBase<LWPacketGraphData> {
    
    public func requestGraphData(forPeriod period: LWGraphPeriodModel, assetPairId: String, points: Int32) -> Observable<ApiResult<LWPacketGraphData>> {
        return Observable.create{observer in
            let pack = LWPacketGraphData(observer: observer, period: period, assetPairId: assetPairId, points: points)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketGraphData) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGraphData>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketGraphData) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketGraphData>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketGraphData) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGraphData>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketGraphData> {
    public func filterSuccess() -> Observable<LWPacketGraphData> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

public extension ObservableType where Self.E == (apiResult: ApiResult<LWPacketGraphData>, interval: Bool) {
    public func filterSuccess() -> Observable<LWPacketGraphData> {
        return map{$0.apiResult.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return filter{!$0.interval}.map{$0.apiResult.isLoading}
    }
}



extension LWPacketGraphData {
    convenience init(observer: Any, period: LWGraphPeriodModel, assetPairId: String, points: Int32) {
        self.init()
        
        self.period = period
        self.assetId = assetPairId
        self.points = points
        self.observer = observer
    }
}
