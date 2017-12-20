//
//  LWTransferOperationModel.swift
//  LykkeWallet
//
//  Created by Nikita Medvedev on 15/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import EasyMapping

@objc public enum LWOperationType: Int {
	case unknown
	case transfer
}

public class LWOperationModel: LWJSONObject {
	public var identity: String?
	public var type: LWOperationType = .unknown
	public var transfer: LWOperationTransferModel?
	
	public override class func objectMapping() -> EKObjectMapping {
		let mapping = EKObjectMapping(objectClass: self)
		mapping.mapProperties(from: ["Id": "identity"])
		mapping.mapKeyPath("Type", toProperty: "type", withValueBlock: { (key, value) -> LWOperationType.RawValue in
			var result: LWOperationType = .unknown
			if let value = value as? String {
				switch value {
				case "Transfer":
					result = .transfer
				default:
					result = .unknown
				}
			}
			return result.rawValue
		}, reverse: { _ in return "" })
		mapping.hasOne(LWOperationTransferModel.self, forKeyPath: "Transfer", forProperty: "transfer")
		return mapping
	}
}
