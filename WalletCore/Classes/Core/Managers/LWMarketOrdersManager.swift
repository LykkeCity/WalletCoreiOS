//
//  LWMarketOrdersManager.swift
//  LykkeWallet
//
//  Created by Nikita Medvedev on 21/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

class LWMarketOrdersManager: NSObject {

    class func createOrder(assetPair: LWAssetPairModel, assetId: String, isSell: Bool, volume: String, completion: @escaping (LWAssetDealModel?)->()) {
        let anotherAssetId = assetPair.baseAssetId == assetId ? assetPair.quotingAssetId : assetPair.baseAssetId
		
		let asset = LWCache.asset(byId: assetId)
		let anotherAsset = LWCache.asset(byId: anotherAssetId)
		
		let isBaseEthereum = asset?.blockchainType == .ethereum
		let isAnotherEthereum = anotherAsset?.blockchainType == .ethereum
		
		let volumeNumber = NSDecimalNumber(string: volume)
		let signedVolumeNumber = isSell ? volumeNumber.multiplying(by: NSDecimalNumber(value: -1)) : volumeNumber
    let isTrusted = (isSell ? asset?.isTrusted : anotherAsset?.isTrusted) ?? false

		let resultBlock = { (result: [AnyHashable: Any]?) in
			var deal: LWAssetDealModel? = nil
			if let result = result {
				deal = LWAssetDealModel(json: result)
			}
      LWEthereumTransactionsManager.shared().shouldShowOffchainLiquidityError = false
      LWOffchainTransactionsManager.shared().shouldShowOffchainLiquidityError = false
			completion(deal)
		}
		
		let block = {
			let sellEthereum = isBaseEthereum && isSell
			let buyEthereum = isAnotherEthereum && !isSell
			let assetPairId = assetPair.identity
			if isTrusted {
        HotWalletNetworkClient.createMarketOrder(for: assetPairId!, assetId: assetId, volume: signedVolumeNumber, completion: resultBlock)
      }else if sellEthereum || buyEthereum {
        LWEthereumTransactionsManager.shared().shouldShowOffchainLiquidityError = true
        LWEthereumTransactionsManager.shared().requestTrade(forBaseAsset: asset, pair: assetPair, addressTo: "", volume: signedVolumeNumber, completion: resultBlock)
			} else {
        LWOffchainTransactionsManager.shared().shouldShowOffchainLiquidityError = true
        LWOffchainTransactionsManager.shared().sendSwapRequest(forAsset: assetId, pair: assetPairId, volume: signedVolumeNumber, completion: resultBlock)
			}
		}
		
		let isEmpty = { (string: String?) in
			return string == nil || string!.count == 0
		}
		
		var etherAsset: LWAssetModel? = nil
		if isBaseEthereum && isEmpty(asset?.blockchainDepositAddress) {
			etherAsset = asset
		} else if isAnotherEthereum && isEmpty(anotherAsset?.blockchainDepositAddress) {
			etherAsset = anotherAsset
		}
		
		if let etherAsset = etherAsset, !isTrusted {
			LWEthereumTransactionsManager.shared().createEthereumSign(forAsset: etherAsset, completion: {result in
				if result {
					block()
				} else {
					completion(nil)
				}
			})
		} else {
			block()
		}
	}
  
}
