//
//  LWPacketAssetsDescriptions.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetDescriptionModel;


@interface LWPacketAssetsDescriptions : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSArray *assetsIds;
// out
@property (copy, nonatomic) NSArray *assetsDescriptions;

@end
