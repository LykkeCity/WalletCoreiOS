//
//  LWPacketAllAssetPairs.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketAllAssetPairs : LWAuthorizePacket

    @property (strong, nonatomic) NSArray *assetPairs;
    
@end
