//
//  LWPacketBaseAssets.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketBaseAssets : LWAuthorizePacket {
    
}
// out
@property (copy, nonatomic) NSArray *assets; // LWAssetModel's

@end
