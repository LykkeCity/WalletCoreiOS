//
//  LWPacketGetNews.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 30/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketGetNews : LWAuthorizePacket

@property (strong,nonatomic) void(^completion)(NSArray *);

@end
