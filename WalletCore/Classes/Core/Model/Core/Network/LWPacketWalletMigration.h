//
//  LWPacketWalletMigration.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWWalletMigrationModel;

@interface LWPacketWalletMigration : LWAuthorizePacket


@property (strong, nonatomic) LWWalletMigrationModel *migration;

@end
