//
//  LWDeviceType.swift
//  LykkeWallet
//
//  Created by Nikita Medvedev on 01/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

struct ScreenSize
{
	static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
	static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
	static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
	static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

@objc public class DeviceType: NSObject
{
	public static let IS_IPHONE            = UIDevice.current.userInterfaceIdiom == .phone
	public static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
	public static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
	public static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
	public static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
	public static let IS_IPHONE_7          = IS_IPHONE_6
	public static let IS_IPHONE_7P         = IS_IPHONE_6P
	public static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad
	public static let IS_IPAD_PRO_9_7      = IS_IPAD
	public static let IS_IPAD_PRO_12_9     = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

@objc public class Version: NSObject
{
	public static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
	public static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
	public static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
	public static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
	public static let iOS10 = (Version.SYS_VERSION_FLOAT >= 10.0 && Version.SYS_VERSION_FLOAT < 11.0)
}
