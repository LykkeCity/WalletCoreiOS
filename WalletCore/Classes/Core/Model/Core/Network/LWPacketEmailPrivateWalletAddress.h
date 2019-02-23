//
//  LWPacketEmailPrivateWalletAddress.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"



@interface LWPacketEmailPrivateWalletAddress : LWAuthorizePacket

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;

@end
