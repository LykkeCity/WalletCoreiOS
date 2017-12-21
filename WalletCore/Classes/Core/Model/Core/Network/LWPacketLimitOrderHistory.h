//
//  LWPacketLimitOrderHistory.h
//  LykkeWallet
//
//  Created by Nikita Medvedev on 04/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketLimitOrderHistory : LWAuthorizePacket

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSArray *history;

@end
