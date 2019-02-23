//
//  LWPacketAllAssetPairsRates.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWAssetPairRateModel;

@interface LWPacketAllAssetPairsRates : LWAuthorizePacket

@property (copy, nonatomic) NSString *assetId;

@property (strong, nonatomic) LWAssetPairRateModel *rate;

@end

