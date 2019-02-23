//
//  LWPacketCategories.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketCategories : LWAuthorizePacket

@property (strong, nonatomic) NSArray *categories;

@end
