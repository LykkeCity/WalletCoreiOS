//
//  LWPacketClientState.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketClientState : LWAuthorizePacket

@property (copy, nonatomic) NSString *email;

@end
