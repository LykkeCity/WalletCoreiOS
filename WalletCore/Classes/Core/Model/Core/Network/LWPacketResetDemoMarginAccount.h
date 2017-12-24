//
//  LWPacketResetDemoMarginAccount.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketResetDemoMarginAccount : LWAuthorizePacket

@property (strong, nonatomic) NSString *accountId;

@end
