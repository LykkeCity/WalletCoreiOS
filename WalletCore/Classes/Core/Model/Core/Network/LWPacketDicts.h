//
//  LWPacketDicts.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 23.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetsDictionaryItem;


@interface LWPacketDicts : LWAuthorizePacket {
    
}
// out
@property (readonly, nonatomic) NSArray *assetsDictionary;

@end
