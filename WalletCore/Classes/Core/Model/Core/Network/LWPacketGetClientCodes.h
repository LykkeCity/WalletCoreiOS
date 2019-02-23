//
//  LWPacketGetClientCodes.h
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/21/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import <WalletCore/WalletCore.h>

@interface LWPacketGetClientCodes : LWAuthorizePacket

// out
@property (copy, nonatomic) NSString *codeSms;

@end
