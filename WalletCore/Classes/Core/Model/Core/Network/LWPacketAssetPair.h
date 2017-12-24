//
//  LWPacketAssetPair.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 12.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetPairModel;


@interface LWPacketAssetPair : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *identity;

//out
@property (readonly, nonatomic) LWAssetPairModel *assetPair;

@end
