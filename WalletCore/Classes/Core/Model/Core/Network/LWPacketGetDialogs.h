//
//  LWPacketGetDialogs.h
//  LykkeWallet
//
//  Created by Nikita Medvedev on 06/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketGetDialogs : LWAuthorizePacket

@property (strong, nonatomic) NSArray *dialogs;

@end
