//
//  LWPacketGetMainScreenInfo.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketGetMainScreenInfo : LWAuthorizePacket

@property double tradingBalance;
@property double privateBalance;
@property double marginBalance;

@property BOOL success;

@property (strong, nonatomic) NSString *assetId;

@end
