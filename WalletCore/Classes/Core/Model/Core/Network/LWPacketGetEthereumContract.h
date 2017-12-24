//
//  LWPacketGetEthereumContract.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 05/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketGetEthereumContract : LWAuthorizePacket

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *pubKey;

@property (strong, nonatomic) NSString *contract;


@end
