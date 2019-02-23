//
//  LWPacketPostClientCodes.h
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/22/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import <WalletCore/WalletCore.h>

@interface LWPacketPostClientCodes : LWAuthorizePacket

// in
@property (copy, nonatomic) NSString *codeSms;
// out
@property (readonly, nonatomic) NSString *accessToken;

@end
