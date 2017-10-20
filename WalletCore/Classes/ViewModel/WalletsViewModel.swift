//
//  WalletsViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/6/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class WalletsViewModel {
    public var wallets: Observable<[Variable<Asset>]>
    public var isLoading: Observable<Bool>
    
    public init(
        withBaseAsset baseAsset: Observable<LWAssetModel>,
        mainInfo: Observable<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>,
        authManager:LWRxAuthManager = LWRxAuthManager.instance
    ) {
        let walletsObservable = Observable.combineLatest(
            mainInfo,
            authManager.lykkeWallets.requestNonEmptyWallets()
        )
        {(asset: $0.asset, wallets: $1, mainInfo: $0.mainInfo)}
        
        let allAssets = authManager.allAssets.requestAllAssets()
        
        let observable = allAssets
                .filterSuccess()
                .flatMapLatest{_ in walletsObservable}
                .shareReplay(1)
        
        self.isLoading = allAssets.isLoading()
        
        self.wallets = observable.mapToAssets()
    }
}

fileprivate extension ObservableType where Self.E == (
    asset: LWAssetModel,
    wallets: [LWSpotWallet],
    mainInfo: LWPacketGetMainScreenInfo
) {
    func mapToAssets() -> Observable<[Variable<Asset>]> {
        return map{data in
            data.wallets
                .filter{$0.asset != nil}
                .map{Asset(wallet: $0, baseAsset: data.asset, mainInfo: data.mainInfo)}
                .map{Variable($0)}
            }
    }
}
