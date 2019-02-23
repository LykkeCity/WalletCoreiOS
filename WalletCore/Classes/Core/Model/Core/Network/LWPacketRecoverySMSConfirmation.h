//
//  LWPacketRecoverySMSConfirmation.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWRecoveryPasswordModel;

@interface LWPacketRecoverySMSConfirmation : LWAuthorizePacket

@property (strong, nonatomic) LWRecoveryPasswordModel *recModel;



@end
