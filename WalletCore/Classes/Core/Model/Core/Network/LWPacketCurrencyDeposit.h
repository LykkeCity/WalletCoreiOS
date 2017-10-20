//
//  LWPacketCurrencyDeposit.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketCurrencyDeposit : LWAuthorizePacket

@property (copy, nonatomic) NSString *assetId;
@property (copy, nonatomic) NSNumber *balanceChange;

@end
