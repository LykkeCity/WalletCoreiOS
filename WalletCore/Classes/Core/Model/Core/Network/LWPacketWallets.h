//
//  LWPacketWallets.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWLykkeWalletsData.h"


@interface LWPacketWallets : LWAuthorizePacket {
    
}
// out
@property (readonly, nonatomic) LWLykkeWalletsData *data;

@end
