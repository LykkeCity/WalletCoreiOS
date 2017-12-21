//
//  LWDialogsButtonModel.swift
//  LykkeWallet
//
//  Created by Nikita Medvedev on 06/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

public class LWDialogsButtonModel: LWJSONObject {
	
	public var identity: String?
	public var pinRequired = false
	public var text: String?
	
	override convenience init() {
		self.init(json: [:])
	}
	
	override init!(json: Any!) {
		super.init(json: json)
		
		guard let dict = json as? [String: Any] else {
			return
		}
		
		identity = dict["Id"] as? String
		pinRequired = dict["PinRequired"] as! Bool
		text = dict["Text"] as? String
	}
}
