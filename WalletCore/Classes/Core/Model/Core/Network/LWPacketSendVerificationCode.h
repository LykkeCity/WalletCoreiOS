//
//  LWPacketSendVerificationCode.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketSendVerificationCode : LWAuthorizePacket

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *accessToken;
@end
