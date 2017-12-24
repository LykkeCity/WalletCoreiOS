//
//  LWPacketDeleteWatchList.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/02/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWWatchList;
@interface LWPacketDeleteWatchList : LWAuthorizePacket

@property (strong, nonatomic) LWWatchList *watchList;

@end
