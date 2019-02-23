//
//  LWPacketSendSignedSPOTTransactions.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketSendSignedSPOTTransactions : LWAuthorizePacket

@property (strong, nonatomic) NSArray *transactions;

@end
