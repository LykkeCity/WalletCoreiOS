//
//  LWPacketGetRefundAddress.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketGetRefundAddress : LWAuthorizePacket

@property (strong, nonatomic) NSString *refundAddress;
@property int validDays;
@property BOOL sendAutomatically;

@end
