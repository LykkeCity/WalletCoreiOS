//
//  LWPacketCheckIsUSAUser.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/03/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketCheckIsUSAUser : LWAuthorizePacket

@property BOOL isUserFromUSA;

@property (strong, nonatomic) NSString *phoneNumber;


@end
