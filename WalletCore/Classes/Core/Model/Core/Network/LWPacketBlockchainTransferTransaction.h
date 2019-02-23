//
//  LWPacketBlockchainTransferTransaction.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetBlockchainModel;


@interface LWPacketBlockchainTransferTransaction : LWAuthorizePacket {
    
}
// in
@property (assign, nonatomic) NSString *transferOperationId;
// out
@property (readonly, nonatomic) LWAssetBlockchainModel* blockchain;

@end
