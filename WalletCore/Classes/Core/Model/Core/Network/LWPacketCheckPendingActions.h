//
//  LWPacketCheckPendingActions.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketCheckPendingActions : LWAuthorizePacket

@property BOOL hasUnsignedTransactions;
@property BOOL hasOffchainRequests;
@property BOOL needReinit;

@end
