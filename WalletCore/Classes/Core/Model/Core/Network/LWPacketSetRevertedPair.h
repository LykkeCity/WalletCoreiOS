//
//  LWPacketSetRevertedPair.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketSetRevertedPair : LWAuthorizePacket

@property (copy, nonatomic) NSString *assetPairId;
@property BOOL inverted;

@end
