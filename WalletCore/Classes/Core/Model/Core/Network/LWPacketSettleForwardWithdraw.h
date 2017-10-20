//
//  LWPacketSettleForwardWithdraw.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/03/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWAssetModel;

@interface LWPacketSettleForwardWithdraw : LWAuthorizePacket

@property (strong, nonatomic) LWAssetModel *asset;
@property double amount;

@end
