//
//  LWPendingActionDialogModel.swift
//  LykkeWallet
//
//  Created by Nikita Medvedev on 06/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

public enum PendingActionType: String {
	case info = "Info"
	case warning = "Warning"
	case question = "Question"
}

@objc public class LWDialogsModel: LWJSONObject {

	public var identity: String?
	public var title: String?
	public var text: String?
	public var iconType: PendingActionType?
	public var buttons: [LWDialogsButtonModel]?

	override convenience init() {
		self.init(json: [:])
	}

	public override init!(json: Any!) {
		super.init(json: json)

		guard let dict = json as? [String: Any] else {
			return
		}

		identity = dict["Id"] as? String
		title = dict["Caption"] as? String
		text = dict["Text"] as? String
		iconType = PendingActionType(rawValue: (dict["Type"] as? String) ?? "NoTypeProvided")

        let buttonsDicts = (dict["Buttons"] as? [[String: Any]]) ?? [[:]]

		buttons = buttonsDicts.map { LWDialogsButtonModel(json: $0) }
	}

	public func image() -> UIImage {
		switch iconType! {
		case .info:
			return #imageLiteral(resourceName: "action_info")
		case .warning:
			return #imageLiteral(resourceName: "action_alert")
		case .question:
			return #imageLiteral(resourceName: "action_dialog")
		}
	}

}
