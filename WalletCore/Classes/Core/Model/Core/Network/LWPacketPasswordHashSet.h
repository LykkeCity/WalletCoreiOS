//
//  LWPacketPasswordHashSet.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketPasswordHashSet : LWAuthorizePacket

@property (strong, nonatomic) NSString *password;

@end
