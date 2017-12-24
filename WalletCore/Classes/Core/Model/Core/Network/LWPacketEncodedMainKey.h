//
//  LWPacketEncodedMainKey.h
//  WalletCore
//
//  Created by Bozidar Nikolic on 8/22/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import <WalletCore/WalletCore.h>

@interface LWPacketEncodedMainKey : LWAuthorizePacket

// in
@property (copy, nonatomic) NSString *accessToken;
// out
@property (readonly, nonatomic) NSString *encodedPrivateKey;

@end
