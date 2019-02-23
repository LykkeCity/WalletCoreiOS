//
//  LWPacketMyLykkeInfo.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketMyLykkeInfo : LWAuthorizePacket

@property (strong, nonatomic) NSString *conversionAddress;
@property (strong, nonatomic) NSNumber *lkkBalance;
@property (strong, nonatomic) NSNumber *lkkTotalAmount;
@property (strong, nonatomic) NSNumber *marketValue;
@property (strong, nonatomic) NSNumber *myEquityPercent;
@property (strong, nonatomic) NSNumber *numberOfShares;

@end
