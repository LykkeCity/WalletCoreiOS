//
//  LWPacketBlockchainCashTransaction.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetBlockchainModel;


@interface LWPacketBlockchainCashTransaction : LWAuthorizePacket {
    
}
// in
@property (assign, nonatomic) NSString *cashOperationId;
// out
@property (readonly, nonatomic) LWAssetBlockchainModel* blockchain;

@end
