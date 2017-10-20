//
//  LWRxAuthManagerAllAssets.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAllAssets: LWRxAuthManagerBase<LWPacketAllAssets> {
    
    public func requestAssets(byIds ids: [String]) -> Observable<ApiResultList<LWAssetModel>> {
        return requestAllAssets().map{ result -> ApiResultList<LWAssetModel> in
            switch result {
                case .error(let data): return .error(withData: data)
                case .loading: return .loading
                case .notAuthorized: return .notAuthorized
                case .forbidden: return .forbidden
                case .success(let data): return .success(withData: data.filter{ids.contains($0.identity)})
            }
        }
    }
    
    public func requestAsset(byId id: String?) -> Observable<ApiResult<LWAssetModel?>> {
        
        guard let id = id else {
            return Observable
                .just(.success(withData: nil))
                .startWith(.loading)
        }
        
        if let asset = LWCache.asset(byId: id) {
            return Observable
                .just(.success(withData: asset))
                .startWith(.loading)
        }
        
        return requestAllAssets().map{ result -> ApiResult<LWAssetModel?> in
                switch result {
                    case .error(let data): return .error(withData: data)
                    case .loading: return .loading
                    case .notAuthorized: return .notAuthorized
                    case .forbidden: return .forbidden
                    case .success(let data): return .success(withData: data.filter{$0.identity == id}.first)
                }
            }
    }
    
    public func requestAllAssets() -> Observable<ApiResultList<LWAssetModel>> {
        if let allAssets = LWCache.instance().allAssets {
            return Observable
                .just(.success(withData: allAssets.map{$0 as! LWAssetModel}))
                .startWith(.loading)
        }
        
        return Observable.create{observer in
            let paket = LWPacketAllAssets(observer: observer)
            GDXNet.instance().send(paket, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    override func onNotAuthorized(withPacket packet: LWPacketAllAssets) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWAssetModel>> else {return}
        observer.onNext(.notAuthorized)
        observer.onCompleted()
    }
    
    override func onError(withData data: [AnyHashable : Any], pack: LWPacketAllAssets) {
        guard let observer = pack.observer as? AnyObserver<ApiResultList<LWAssetModel>> else {return}
        observer.onNext(.error(withData: data))
        observer.onCompleted()
    }
    
    override func onSuccess(packet: LWPacketAllAssets) {
        guard let observer = packet.observer as? AnyObserver<ApiResultList<LWAssetModel>> else {return}
        let allAssets = LWCache.instance().allAssets.map{$0 as! LWAssetModel}

        observer.onNext(.success(withData: allAssets))
        observer.onCompleted()
    }
}

public extension ObservableType where Self.E == ApiResult<LWAssetModel?> {
    public func filterSuccess() -> Observable<LWAssetModel?> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

//TODO: Make this code to use generics
public extension ObservableType where Self.E == ApiResultList<LWAssetModel> {
    public func filterSuccess() -> Observable<[LWAssetModel]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

extension LWPacket {
    convenience init(observer: Any) {
        self.init()
        self.observer = observer
    }
}
