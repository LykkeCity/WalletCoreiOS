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
    
    public let loadingViewModel: LoadingViewModel
    
    init(blueAuthManager: LWRxBlueAuthManager = LWRxBlueAuthManager.instance,
         authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        
        let comunityUsersCountRequest =  blueAuthManager.getCommunityUsersCount.request()
        
        communityUsersCount = comunityUsersCountRequest.filterSuccess()
            .map { NumberFormatter.currencyInstance(accuracy: 0).string(from: $0 as NSNumber) }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
        
        let walletRequest = authManager.lykkeWallets.request(byAssetId: blueAuthManager.treeCoinIdentifier)
        
        let wallet = walletRequest.filterSuccess().filterNil().shareReplay(1)
        
        treesCount = wallet
            .map { NumberFormatter.currencyInstance(accuracy: $0.accuracy.intValue).string(from: $0.balance) }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
        
        treeName = wallet
            .map { $0.asset.displayId }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
        
        let baseAssetRequest = authManager.baseAsset.request()
        
        amountInBaseAsset = Observable.combineLatest(wallet, baseAssetRequest.filterSuccess())
            .map { data in
                let (wallet, baseAsset) = data
                return wallet.amountInBase.decimalValue.convertAsCurrency(asset: baseAsset)
            }
            .asDriver(onErrorJustReturn: "")

        loadingViewModel = LoadingViewModel([comunityUsersCountRequest.isLoading(), walletRequest.isLoading(), baseAssetRequest.isLoading()])
    }
    
}
