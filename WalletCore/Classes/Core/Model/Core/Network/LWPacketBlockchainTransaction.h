//
//  LWPacketBlockchainTransaction.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetBlockchainModel;


@interface LWPacketBlockchainTransaction : LWAuthorizePacket {
    
}
// in
@property (assign, nonatomic) NSString *orderId;
// out
@property (readonly, nonatomic) LWAssetBlockchainModel* blockchain;

@end
