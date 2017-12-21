//
//  LWPacketEncodedPrivateKey.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketEncodedPrivateKey : LWAuthorizePacket

@property (strong, nonatomic) NSString *accessToken;

@property BOOL needGeneratePrivateKey;

@end
