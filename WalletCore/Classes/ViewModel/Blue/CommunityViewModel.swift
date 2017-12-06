//
//  CommunityViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 4.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class CommunityViewModel {
    
    public let communityUsersCount: Driver<String>
    
    public let treesCount: Driver<String>
    
    public let treeName: Driver<String>
    
    public let amountInBaseAsset: Driver<String>
    
    public let zeroBalance: Driver<Bool>
    
    public let loadingViewModel: LoadingViewModel
    
    public init(
        triggerRefresh: Observable<Void>,
        blueAuthManager: LWRxBlueAuthManager = LWRxBlueAuthManager.instance,
        authManager: LWRxAuthManager = LWRxAuthManager.instance
    ) {
        //arrange requests
        let comunityUsersCountRequest = triggerRefresh
            .flatMap{ blueAuthManager.getCommunityUsersCount.request() }
            .shareReplay(1)
        
        let walletRequest = triggerRefresh
            .flatMap{ authManager.lykkeWallets.request(byAssetId: blueAuthManager.treeCoinIdentifier) }
            .shareReplay(1)
        
        let baseAssetRequest = triggerRefresh
            .flatMap{ authManager.baseAsset.request() }
            .shareReplay(1)
        
        communityUsersCount = comunityUsersCountRequest.filterSuccess()
            .map { NumberFormatter.currencyInstance(accuracy: 0).string(from: $0 as NSNumber) }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
        
        let wallet = walletRequest.filterSuccess().filterNil().shareReplay(1)
        
        treesCount = wallet
            .map { NumberFormatter.currencyInstance(accuracy: 0).string(from: $0.balance) }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
        
        treeName = wallet
            .map { $0.asset.displayId }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
        
        amountInBaseAsset = Observable.combineLatest(wallet, baseAssetRequest.filterSuccess())
            .map { data in
                let (wallet, baseAsset) = data
                return wallet.amountInBase.decimalValue.convertAsCurrency(asset: baseAsset)
            }
            .asDriver(onErrorJustReturn: "")
        
        zeroBalance = wallet.map{$0.balance == 0.0}.asDriver(onErrorJustReturn: true)
        
        //show loading indicator only for initial loading
        loadingViewModel = LoadingViewModel([
            comunityUsersCountRequest.isLoading().take(2),
            walletRequest.isLoading().take(2),
            baseAssetRequest.isLoading().take(2)
        ])
    }
}
