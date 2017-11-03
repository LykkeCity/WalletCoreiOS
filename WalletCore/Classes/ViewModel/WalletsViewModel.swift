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
            .flatMap{ _ in
                authManager.lykkeWallets.requestNonEmptyWallets()
                    .map{ ApiResultList.success(withData: $0) }
                    .startWith( ApiResultList.loading )
            }
            .shareReplay(1)
        
        let allAssets = authManager.allAssets.requestAllAssets()
        
        let walletsObservable = Observable
            .combineLatest(mainInfo, nonEmptyWallets.filterSuccess(), allAssets.filterSuccess())
            .map{mainInfo, wallets, _ in
                (asset: mainInfo.asset, wallets: wallets, mainInfo: mainInfo.mainInfo)
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
