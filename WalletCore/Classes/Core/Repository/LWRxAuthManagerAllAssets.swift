//
//  LWRxAuthManagerAllAssets.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerAllAssets: NSObject{
    
    public typealias Packet = LWPacketAllAssets
    public typealias Result = ApiResultList<LWAssetModel>
    public typealias RequestParams = Void
    
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

extension LWRxAuthManagerAllAssets: AuthManagerProtocol{
    
    public func request(byIds ids: [String]) -> Observable<ApiResultList<LWAssetModel>> {
        return request(withParams:()).map{ result -> ApiResultList<LWAssetModel> in
            switch result {
                case .error(let data): return .error(withData: data)
                case .loading: return .loading
                case .notAuthorized: return .notAuthorized
                case .forbidden: return .forbidden
                case .success(let data): return .success(withData: data.filter{ids.contains($0.identity)})
            }
        }
    }
    
    public func request(byId id: String?) -> Observable<ApiResult<LWAssetModel?>> {
        
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
        
        return request(withParams: ()).map{ result -> ApiResult<LWAssetModel?> in
                switch result {
                    case .error(let data): return .error(withData: data)
                    case .loading: return .loading
                    case .notAuthorized: return .notAuthorized
                    case .forbidden: return .forbidden
                    case .success(let data): return .success(withData: data.filter{$0.identity == id}.first)
                }
            }
    }
    
    public func request(withParams: RequestParams = RequestParams()) -> Observable<Result> {
        if let allAssets = LWCache.instance().allAssets, allAssets.isNotEmpty {
            return Observable
                .just(.success(withData: allAssets.map{$0 as! LWAssetModel}))
                .startWith(.loading)
        }
        
        return Observable.create{observer in
            let paket = Packet(observer: observer)
            GDXNet.instance().send(paket, userInfo: nil, method: .REST)
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
    
    func getErrorResult(fromPacket packet: Packet) -> Result {
        return Result.error(withData: packet.errors)
    }
    
    func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: LWCache.instance().allAssets.map{$0 as! LWAssetModel})
    }
    
    func getForbiddenResult(fromPacket packet: Packet) -> Result {
        return Result.forbidden
    }
    
    func getNotAuthrorizedResult(fromPacket packet: Packet) -> Result {
        return Result.notAuthorized
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
