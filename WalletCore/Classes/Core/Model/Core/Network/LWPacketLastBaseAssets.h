//
//  LWPacketLastBaseAssets.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketLastBaseAssets : LWAuthorizePacket


@property (strong, nonatomic) NSArray *lastAssets;

@end
