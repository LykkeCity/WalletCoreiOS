//
//  LWPacketCashOut.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketCashOut : LWAuthorizePacket {
    
}

// in
@property (assign, nonatomic) NSString *multiSig;
@property (assign, nonatomic) NSNumber *amount;
@property (assign, nonatomic) NSString *assetId;

@end
