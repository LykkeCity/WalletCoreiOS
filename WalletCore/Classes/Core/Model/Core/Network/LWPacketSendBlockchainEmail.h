//
//  LWPacketSendBlockchainEmail.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketSendBlockchainEmail : LWAuthorizePacket {
    
}

@property (copy, nonatomic) NSString *assetId;
@property (copy, nonatomic) NSString *address;

@end
