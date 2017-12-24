//
//  LWPacketAssetPairRates.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketAssetPairRates : LWAuthorizePacket {
    
}
// out
@property (copy, nonatomic) NSArray *assetPairRates;
    
    @property BOOL ignoreBaseAsset;

@end
