//
//  LWPacketGetBlockchainAddress.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/03/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketGetBlockchainAddress : LWAuthorizePacket

@property (strong, nonatomic) NSString *assetId;

@property (strong, nonatomic) NSString *address;

@end
