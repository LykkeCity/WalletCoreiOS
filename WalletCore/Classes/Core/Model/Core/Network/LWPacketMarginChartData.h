//
//  LWPacketMarginChartData.h
//  LykkeWallet
//
//  Created by Nikita Medvedev on 24/07/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketMarginChartData : LWAuthorizePacket

@property (strong, nonatomic) NSArray *assetIds;

@property (strong, nonatomic) NSDictionary *chartData;

@end
