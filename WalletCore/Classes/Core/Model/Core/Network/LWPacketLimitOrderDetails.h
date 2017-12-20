//
//  LWLimitOrderDetailsPacket.h
//  LykkeWallet
//
//  Created by Nikita Medvedev on 21/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWExchangeInfoModel.h"

@interface LWPacketLimitOrderDetails : LWAuthorizePacket

@property (strong, nonatomic) NSString *orderId;

@property (strong, nonatomic) LWExchangeInfoModel *marketOrder;

@end
