//
//  LWPacketMarketConverter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketMarketConverter : LWAuthorizePacket

@property (strong, nonatomic) NSDictionary *assetsDict;

@property (strong, nonatomic) NSArray *converted;
@property (strong, nonatomic) NSString *lkkAssetId;


@end
