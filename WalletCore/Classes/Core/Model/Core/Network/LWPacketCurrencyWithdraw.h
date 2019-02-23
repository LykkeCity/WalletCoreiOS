//
//  LWPacketCurrencyWithdraw.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketCurrencyWithdraw : LWAuthorizePacket

@property (copy, nonatomic) NSString *assetId;

@property (copy, nonatomic) NSString *bic;
@property (copy, nonatomic) NSString *accountNumber;
@property (copy, nonatomic) NSString *accountName;
@property (copy, nonatomic) NSString *postCheck;
@property (copy, nonatomic) NSNumber *amount;

@property (copy, nonatomic) NSString *bankName;
@property (copy, nonatomic) NSString *holderAddress;

@end
