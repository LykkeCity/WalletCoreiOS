//
//  LWPacketGetHistory.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketGetHistory : LWAuthorizePacket

@property (strong, nonatomic) NSArray *historyArray;

@property (strong, nonatomic) NSString *assetId;

@end
