//
//  LWMainScreenData.swift
//  LykkeWallet
//
//  Created by Nikita Medvedev on 24/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import EasyMapping

@objc public class LWMainScreenData: LWJSONObject {
	public var total: String?
	public var trading: String?
	public var privatee: String?
	public var margin: String?

	public class override func objectMapping() -> EKObjectMapping {
		return EKObjectMapping(for: self, with: { mapping in
			mapping.mapProperties(from: ["total", "trading", "privatee", "margin"])
		})
	}

	override init() {
		super.init()
	}

	init(total: String?, trading: String?, privatee: String?, margin: String) {
		super.init()

		self.total = total
		self.trading = trading
		self.privatee = privatee
		self.margin = margin
	}
}
