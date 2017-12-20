//
//  LWPacketMarginSwiftWithdraw.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/06/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketMarginSwiftWithdraw : LWAuthorizePacket

@property (strong, nonatomic) NSDictionary *credentials;

@end
