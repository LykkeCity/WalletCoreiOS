//
//  LWPacketSendDialog.h
//  LykkeWallet
//
//  Created by Nikita Medvedev on 06/09/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketSendDialog : LWAuthorizePacket

@property (strong, nonatomic) NSString *dialogId;
@property (strong, nonatomic) NSString *buttonId;

@end
