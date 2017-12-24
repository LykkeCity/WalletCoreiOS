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
    public var loadingViewModel: LoadingViewModel
    
    public init(
        refreshWallets: Observable<Void>,
        mainInfo: Observable<(mainInfo: LWPacketGetMainScreenInfo, asset: LWAssetModel)>,
        authManager:LWRxAuthManager = LWRxAuthManager.instance
    ) {
        let nonEmptyWallets = refreshWallets
            .flatMapLatest{ _ in authManager.lykkeWallets.requestNonEmptyWallets() }
            .shareReplay(1)
        
        let allAssets = authManager.allAssets.request()
        
        let walletsObservable = Observable
            .combineLatest(mainInfo, nonEmptyWallets.filterSuccess(), allAssets.filterSuccess())
            .map{ mainInfo, wallets, assets in
                (asset: mainInfo.asset, wallets: wallets, mainInfo: mainInfo.mainInfo, assets: assets)
            }
            .shareReplay(1)
        
        self.loadingViewModel = LoadingViewModel([
            allAssets.isLoading(),
            nonEmptyWallets.isLoading()
        ])
        
        self.wallets = walletsObservable.mapToAssets()
    }
}

fileprivate extension ObservableType where Self.E == (
    asset: LWAssetModel,
    wallets: [LWSpotWallet],
    mainInfo: LWPacketGetMainScreenInfo,
    assets: [LWAssetModel]
) {
    func mapToAssets() -> Observable<[Variable<Asset>]> {
        return map{ data in
            
            data.wallets.forEach{ wallet in
                wallet.asset = data.assets.first{ $0.identity == wallet.identity }
            }
            
            return data.wallets
                .filter{ $0.asset != nil }
                .map{ Asset(wallet: $0, baseAsset: data.asset, mainInfo: data.mainInfo) }
                .map{ Variable($0) }
            }
    }
}
