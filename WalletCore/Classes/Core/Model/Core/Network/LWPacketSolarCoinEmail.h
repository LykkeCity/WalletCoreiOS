//
//  LWPacketSolarCoinEmail.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 06/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketSolarCoinEmail : LWAuthorizePacket

@property (strong, nonatomic) NSString *address;

@end
