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
    public var walletsData: Observable<[Variable<LWAddMoneyCryptoCurrencyModel>]>
    public var isLoading: Observable<Bool>
    public init(
        authManager: LWRxAuthManager = LWRxAuthManager.instance
        ) {

        let allWallets = authManager.lykkeWallets.request()

        isLoading = allWallets.isLoading()

        self.walletsData = allWallets.filterSuccess().map {$0.lykkeData.wallets.filter {
            return ($0 as! LWSpotWallet).asset.blockchainDeposit && (($0 as! LWSpotWallet).asset.blockchainDepositAddress != nil)
            }.map({ (wallet) -> Variable<LWAddMoneyCryptoCurrencyModel> in
                let w: LWSpotWallet = wallet as! LWSpotWallet
                let model = LWAddMoneyCryptoCurrencyModel(name: w.name,
                                                          address: w.asset.blockchainDepositAddress,
                                                          imageUrl: w.asset.iconUrl)
                return Variable(model)
            })

        }

    }
}
