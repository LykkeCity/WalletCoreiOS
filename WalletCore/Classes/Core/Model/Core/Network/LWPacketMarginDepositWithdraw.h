//
//  LWPacketMarginDepositWithdraw.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketMarginDepositWithdraw : LWAuthorizePacket

@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSNumber *amount;

@end
