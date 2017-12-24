//
//  LWPacketVoiceCall.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketVoiceCall : LWAuthorizePacket

@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *email;

@end
