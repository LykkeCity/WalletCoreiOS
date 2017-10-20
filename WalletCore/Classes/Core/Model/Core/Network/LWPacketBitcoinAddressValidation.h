//
//  LWPacketBitcoinAddressValidation.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketBitcoinAddressValidation : LWAuthorizePacket

@property (copy, nonatomic) NSString *bitcoinAddress;
@property BOOL isValid;

@end
