//
//  LWRxAuthManagerMainInfo.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerMainInfo: LWRxAuthManagerBase<LWPacketGetMainScreenInfo> {
    

    public func requestMainScreenInfo(assetId: String) -> Observable<ApiResult<LWPacketGetMainScreenInfo>> {
        return Observable.create{observer in
            let pack = LWPacketGetMainScreenInfo(observer: observer, assetId: assetId)
            GDXNet.instance().send(pack, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    
    ///
    ///
    /// - Parameters:
    ///   - assetObservable: <#assetObservable description#>
    ///   - authManager: <#authManager description#>
    /// - Returns: <#return value description#>
    func requestMainScreenInfo(
        withAssetObservable assetObservable: Observable<ApiResult<LWAssetModel>>,
        authManager: LWRxAuthManager = LWRxAuthManager.instance
    )-> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> {
        
        let mainScreen = assetObservable
                .filterSuccess()
                .flatMapToMainInfoAndAsset(withManager: authManager)
                .shareReplay(1)
        
        let asset = assetObservable
            .flatMapToInfoAndAsset(withManager: authManager)
            .shareReplay(1)
        
        return Observable.merge(asset, mainScreen)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketGetMainScreenInfo) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGetMainScreenInfo>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketGetMainScreenInfo) {
        guard let observer = pack.observer as? AnyObserver<ApiResult<LWPacketGetMainScreenInfo>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketGetMainScreenInfo) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGetMainScreenInfo>> else {return}
        observer.onNext(.success(withData: packet))
        observer.onCompleted()
    }
    
    override func onForbidden(withPacket packet: LWPacketGetMainScreenInfo) {
        guard let observer = packet.observer as? AnyObserver<ApiResult<LWPacketGetMainScreenInfo>> else {return}
        observer.onNext(.forbidden)
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWPacketGetMainScreenInfo> {
    public func filterSuccess() -> Observable<LWPacketGetMainScreenInfo> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

public extension ObservableType where Self.E == ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)> {
    public func filterSuccess() -> Observable<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacketGetMainScreenInfo {
    convenience init(observer: Any, assetId: String) {
        self.init()
        self.observer = observer
        self.assetId = assetId
    }
}

fileprivate extension ObservableType where Self.E == ApiResult<LWAssetModel> {
    func flatMapToInfoAndAsset(withManager authManager: LWRxAuthManager)
        -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> {
            
        return flatMapLatest{assetResult
            -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> in
            
            switch assetResult {
            case .error(let data): return Observable.just(.error(withData: data))
            case .loading: return Observable.just(.loading)
            case .notAuthorized: return Observable.just(.notAuthorized)
            case .forbidden: return Observable.just(.forbidden)
            case .success(let _): return Observable.never()
            }
        }
    }
}

fileprivate extension ObservableType where Self.E == LWAssetModel {
    func flatMapToMainInfoAndAsset(withManager authManager: LWRxAuthManager)
        -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> {
            
        return flatMapLatest{asset -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> in
            
            return authManager.mainInfo
                .requestMainScreenInfo(assetId: asset.identity)
                .flatMap{mainInfoResult
                    -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> in
                    
                    switch mainInfoResult {
                    case .error(let data): return Observable.just(.error(withData: data))
                    case .loading: return Observable.never()
                    case .notAuthorized: return Observable.just(.notAuthorized)
                    case .forbidden: return Observable.just(.forbidden)
                    case .success(let mainInfo): return Observable.just(.success(withData: (mainInfo: mainInfo, asset: asset)))
                    }
            }
        }
    }
}
