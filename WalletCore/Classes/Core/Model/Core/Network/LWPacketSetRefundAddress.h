//
//  LWPacketSetRefundAddress.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketSetRefundAddress : LWAuthorizePacket

@property (strong, nonatomic) NSDictionary *refundDict;
@end
