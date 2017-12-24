//
//  LWPacketOrderBook.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWOrderBookElementModel.h"

@interface LWPacketOrderBook : LWAuthorizePacket

@property (strong, nonatomic) NSString *assetPairId;
@property (strong, nonatomic) LWOrderBookElementModel *buyOrders;
@property (strong, nonatomic) LWOrderBookElementModel *sellOrders;

@end
