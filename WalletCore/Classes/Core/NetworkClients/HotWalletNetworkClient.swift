//
//  HotWalletNetworkClient.swift
//  LykkeWallet
//
//  Created by vsilux on 21/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

class HotWalletNetworkClient: LWNetworkTemplate, LWNetworkClient {

  private static let shared = HotWalletNetworkClient()

  override func showOffchainErrors() -> Bool {
    return true
  }

  func postRequest(withAPI apiMethod: String!, signatureVerification token: String, params: [AnyHashable: Any]!) -> NSMutableURLRequest! {
    let request = super.postRequest(withAPI: apiMethod, params: params)!
    request.addValue(token, forHTTPHeaderField: "SignatureVerificationToken")
    return request
  }

  class func createMarketOrder(for assetPairId: String, assetId: String, volume: NSDecimalNumber, completion: @escaping ([AnyHashable: Any]?)->Void) {
    LWSignatureVerificationTokenHelper.networkClient(shared, requestVerificationTokenFor: LWKeychainManager.instance().login, success: { (token) in
      let params: [AnyHashable: Any] = ["AssetPair": assetPairId,
                                        "AssetId": assetId,
                                        "Volume": volume]
      let request = shared.postRequest(withAPI: "HotWallet/marketOrder", signatureVerification: token!, params: params)!
      let response = shared.send(request as URLRequest)
      DispatchQueue.main.async {
        if let response = response as? [AnyHashable: Any],
          let order = response["Order"] as? [AnyHashable: Any] {
          completion(order)
        } else {
          completion(nil)
        }
      }
    }) { (_) in
      DispatchQueue.main.async {
        completion(nil)
      }
    }
  }

  class func createLimitOrder(for assetPairId: String, assetId: String, volume: String, price: String, completion: @escaping (Bool)->Void) {
    LWSignatureVerificationTokenHelper.networkClient(shared, requestVerificationTokenFor: LWKeychainManager.instance().login, success: { (token) in
      let params: [AnyHashable: Any] = ["AssetPair": assetPairId,
                                        "AssetId": assetId,
                                        "Volume": NSDecimalNumber(string: volume),
                                        "Price": NSDecimalNumber(string: price)]
      let request = shared.postRequest(withAPI: "HotWallet/limitOrder", signatureVerification: token!, params: params)!
      let response = shared.send(request as URLRequest)
      DispatchQueue.main.async {
        completion(response is [AnyHashable: Any])
      }
    }) { (_) in
      DispatchQueue.main.async {
        completion(false)
      }
    }
  }

  class func cachout(to destinationAddress: String, assetId: String, volume: NSDecimalNumber, completion: @escaping (Bool)->Void) {
    LWSignatureVerificationTokenHelper.networkClient(shared, requestVerificationTokenFor: LWKeychainManager.instance().login, success: { (token) in
      let params: [String: Any] = ["DestinationAddress": destinationAddress,
                                        "AssetId": assetId,
                                        "Volume": volume]
      let request = shared.postRequest(withAPI: "HotWallet/cashout", signatureVerification: token!, params: params)!
      let response = shared.send(request as URLRequest)
      if response is NSError {
        completion(false)
      } else {
        completion(true)
      }
    }) { (_) in
      DispatchQueue.main.async {
        completion(false)
      }
    }
  }

	override func showKycErrors() -> Bool {
		return false
	}
}
