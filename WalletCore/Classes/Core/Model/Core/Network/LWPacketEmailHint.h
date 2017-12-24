//
//  LWPacketEmailHint.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketEmailHint : LWAuthorizePacket

@property (strong, nonatomic) NSString *email;

@end
