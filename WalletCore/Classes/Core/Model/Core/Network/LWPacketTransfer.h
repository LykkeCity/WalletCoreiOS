//
//  LWPacketTransfer.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketTransfer : LWAuthorizePacket {
    
}

// in
@property (copy, nonatomic) NSString *assetId;
@property (copy, nonatomic) NSString *recepientId;
@property (copy, nonatomic) NSNumber *amount;

@end
