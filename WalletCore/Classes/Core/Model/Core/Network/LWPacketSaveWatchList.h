//
//  LWPacketSaveWatchList.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/02/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWWatchList.h"

@interface LWPacketSaveWatchList : LWAuthorizePacket

@property (strong, nonatomic) LWWatchList *watchList;

@end
