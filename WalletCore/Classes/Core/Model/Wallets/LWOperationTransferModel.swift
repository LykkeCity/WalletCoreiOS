//
//  LWTransferOperationModel.swift
//  LykkeWallet
//
//  Created by Nikita Medvedev on 08/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

@objc public enum LWOperationTransferType: Int {
	case unknown
	case tradingToTrusted
	case trustedToTrusted
	case trustedToTrading
}

public class LWOperationTransferModel: LWJSONObject {
  public var assetId: String?
  public var amount: NSDecimalNumber?
  public var sourceWalletId: String?
  public var walletId: String?
  public var transferType: LWOperationTransferType = .unknown

  public override class func objectMapping() -> EKObjectMapping {
    let mapping = EKObjectMapping(objectClass: self)
    mapping.mapPropertiesFromArray(toPascalCase: ["assetId",
                                                  "amount",
                                                  "sourceWalletId",
                                                  "walletId"])
	mapping.mapKeyPath("TransferType", toProperty: "transferType", withValueBlock: { (_, value) -> LWOperationTransferType.RawValue in
		var result: LWOperationTransferType = .unknown
		if let value = value as? String {
			switch value {
			case "TradingToTrusted":
				result = .tradingToTrusted
			case "TrustedToTrusted":
				result = .trustedToTrusted
			case "TrustedToTrading":
				result = .trustedToTrading
			default:
				result = .unknown
			}
		}
		return result.rawValue
	}, reverse: { _ in return "" })

    return mapping
  }
}
