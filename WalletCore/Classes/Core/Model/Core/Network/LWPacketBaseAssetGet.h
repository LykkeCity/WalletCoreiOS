//
//  LWPacketBaseAssetGet.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWAssetModel.h"


@interface LWPacketBaseAssetGet : LWAuthorizePacket {
    
}
// out
@property (copy, nonatomic) LWAssetModel *asset;

@end
