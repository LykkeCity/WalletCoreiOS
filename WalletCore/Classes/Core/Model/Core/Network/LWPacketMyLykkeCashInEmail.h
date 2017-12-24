//
//  LWPacketMyLykkeCashInEmail.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketMyLykkeCashInEmail : LWAuthorizePacket

@property (strong, nonatomic) NSString *assetId;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *lkkAmount;
@property (strong, nonatomic) NSNumber *price;


@end
