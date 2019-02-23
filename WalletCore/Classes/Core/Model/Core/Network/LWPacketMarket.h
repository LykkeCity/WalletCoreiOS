//
//  LWPacketMarket.h
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//


#import "LWAuthorizePacket.h"

@interface LWPacketMarket : LWPacket
    // out
    @property (copy, nonatomic) NSArray *marketAssetPairs;
@end
