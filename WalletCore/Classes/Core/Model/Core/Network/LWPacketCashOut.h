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
@property (copy, nonatomic) NSString *multiSig;
@property (strong, nonatomic) NSNumber *amount;
@property (copy, nonatomic) NSString *assetId;

@end
