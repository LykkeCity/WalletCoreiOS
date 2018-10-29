//
//  CryptoCurrenciesViewModel.swift
//  WalletCore
//
//  Created by Ivan Stefanovic on 12/22/17.
//

import Foundation
import RxSwift
import RxCocoa

open class CryptoCurrenciesViewModel {
    
    public var walletsData : Observable<[Variable<LWAddMoneyCryptoCurrencyModel>]>
    public var isLoading: Observable<Bool>
    
    public init(authManager:LWRxAuthManager = LWRxAuthManager.instance) {
        
        let allWallets = authManager.lykkeWallets.request()
        
        isLoading = allWallets.isLoading()
        
        walletsData = allWallets
            .filterSuccess()
            .map{ $0.lykkeData.wallets.castToWallets().mapToCCModels() }
        
    }
}

private extension Array where Element == Any {
    
    /// Cast Any To Wallets
    ///
    /// - Returns: An array of LWSpotWallet
    func castToWallets() -> [LWSpotWallet] {
        return map{ $0 as? LWSpotWallet }.flatMap{ $0 }
    }
}

private extension Array where Element == LWSpotWallet {
    
    /// Filter wallets with blockchainDeposit and blockchainDepositAddress and map them to LWAddMoneyCryptoCurrencyModel
    ///
    /// - Returns: An array with filtered and transformed LWSpotWallets
    func mapToCCModels() -> [Variable<LWAddMoneyCryptoCurrencyModel>] {
        return
            filter { $0.asset.blockchainDeposit }
            .map{ wallet -> Variable<LWAddMoneyCryptoCurrencyModel> in
                let model = LWAddMoneyCryptoCurrencyModel(asset:wallet.asset,
                                                          name:wallet.name,
                                                          address:wallet.asset.blockchainDepositAddress,
                                                          imageUrl:wallet.asset.iconUrl)
                return Variable(model)
        }
    }
}


