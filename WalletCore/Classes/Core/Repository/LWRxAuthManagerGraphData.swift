//
//  LWRxAuthManagerGraphData.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerGraphData: NSObject{
    
    public typealias Packet = LWPacketGraphData
    public typealias Result = ApiResult<LWPacketGraphData>
    public typealias RequestParams = (period: LWGraphPeriodModel, assetPairId: String, points: Int32)
    
    override init() {
        super.init()
        subscribe(observer: self, succcess: #selector(self.successSelector(_:)), error: #selector(self.errorSelector(_:)))
    }
    
    deinit {
        unsubscribe(observer: self)
    }
    
    @objc func successSelector(_ notification: NSNotification) {
        onSuccess(notification)
    }
    
    @objc func errorSelector(_ notification: NSNotification) {
        onError(notification)
    }
}

extension LWRxAuthManagerGraphData: AuthManagerProtocol{
    
    public func request(withParams params:RequestParams) -> Observable<ApiResult<LWPacketGraphData>> {
        return Observable.create{observer in
            let pack = Packet(observer: observer, period: params.period, assetPairId: params.assetPairId, points: params.points)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return Result.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: packet)
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
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
