//
//  LWRxAuthManagerMainInfo.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerMainInfo: NSObject {

    public typealias Packet = LWPacketGetMainScreenInfo
    public typealias Result = ApiResult<LWPacketGetMainScreenInfo>
    public typealias ResultType = LWPacketGetMainScreenInfo
    public typealias RequestParams = (String)

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

extension LWRxAuthManagerMainInfo: AuthManagerProtocol {

    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketGetMainScreenInfo {
        return Packet(observer: observer, assetId: params)
    }

    ///
    ///
    /// - Parameters:
    ///   - assetObservable: <#assetObservable description#>
    ///   - authManager: <#authManager description#>
    /// - Returns: <#return value description#>
    func request(
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

        return flatMapLatest {assetResult
            -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> in

            switch assetResult {
            case .error(let data): return Observable.just(.error(withData: data))
            case .loading: return Observable.just(.loading)
            case .notAuthorized: return Observable.just(.notAuthorized)
            case .forbidden: return Observable.just(.forbidden)
            case .success: return Observable.never()
            }
        }
    }
}

fileprivate extension ObservableType where Self.E == LWAssetModel {
    func flatMapToMainInfoAndAsset(withManager authManager: LWRxAuthManager)
        -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> {

        return flatMapLatest {asset -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> in

            return authManager.mainInfo
                .request(withParams: (asset.identity))
                .flatMap {mainInfoResult
                    -> Observable<ApiResult<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>> in

                    switch mainInfoResult {
                    case .error(let data): return Observable.just(.error(withData: data))
                    case .loading: return Observable.just(.loading)
                    case .notAuthorized: return Observable.just(.notAuthorized)
                    case .forbidden: return Observable.just(.forbidden)
                    case .success(let mainInfo): return Observable.just(.success(withData: (mainInfo: mainInfo, asset: asset)))
                    }
            }
        }
    }
}
