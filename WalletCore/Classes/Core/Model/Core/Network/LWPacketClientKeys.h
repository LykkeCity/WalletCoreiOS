//
//  LWClientKeys.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketClientKeys : LWAuthorizePacket

@property (copy, nonatomic) NSString *pubKey;
@property (copy, nonatomic) NSString *encodedPrivateKey;

@end
