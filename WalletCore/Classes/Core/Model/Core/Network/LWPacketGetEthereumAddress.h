//
//  LWPacketGetEthereumAddress.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketGetEthereumAddress : LWAuthorizePacket

@property (strong, nonatomic) NSString *ethereumAddress;

@end
