//
//  LWPacketAssetPairRate.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetPairRateModel;


@interface LWPacketAssetPairRate : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *identity;
// out
@property (copy, nonatomic) LWAssetPairRateModel *assetPairRate;

@end
