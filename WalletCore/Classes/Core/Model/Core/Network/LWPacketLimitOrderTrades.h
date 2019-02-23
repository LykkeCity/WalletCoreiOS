//
//  LWPacketLimitOrderTrades.h
//  LykkeWallet
//
//  Created by Nikita Medvedev on 23/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketLimitOrderTrades : LWAuthorizePacket

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSArray *history;

@end
