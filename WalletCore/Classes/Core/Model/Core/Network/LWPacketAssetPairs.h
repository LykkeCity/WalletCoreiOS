//
//  LWPacketAssetPairs.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketAssetPairs : LWAuthorizePacket {
    
}
// out
@property (copy, nonatomic) NSArray *assetPairs;

@end
