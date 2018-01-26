//
//  LWPacketAPIVersion.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketApplicationInfo : LWAuthorizePacket


@property (copy, nonatomic) NSString *apiVersion;
@property (copy, nonatomic) NSString *termsOfUse;

@end
