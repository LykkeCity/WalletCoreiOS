//
//  LWLimitOrder.h
//  LykkeWallet
//
//  Created by Nikita Medvedev on 11/08/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"

static NSString *kLimitOrderTypeBuy = @"Buy";
static NSString *kLimitOrderTypeSell = @"Sell";

@interface LWLimitOrderModel : LWJSONObject

@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *volume;
@property (strong, nonatomic) NSNumber *totalCost;
@property (strong, nonatomic) NSNumber *remainingVolume;
@property (strong, nonatomic) NSNumber *remainingOtherVolume;
@property (strong, nonatomic) NSString *assetPair;

@property (strong, readonly, nonatomic) NSString *asset;
@property (strong, readonly, nonatomic) NSString *quotingAsset;

@property (strong, readonly, nonatomic) NSString *assetDisplayingId;
@property (strong, readonly, nonatomic) NSString *quotingAssetDisplayingId;

@property (assign, readonly, nonatomic) BOOL isSell;
@property (assign, readonly, nonatomic) BOOL isBuy;

@property (strong, readonly, nonatomic) NSString *formattedPrice;

@property (strong, readonly, nonatomic) NSString *formattedVolume;
@property (strong, readonly, nonatomic) NSString *formattedTotalCost;

@property (strong, readonly, nonatomic) NSString *formattedRemainingVolume;
@property (strong, readonly, nonatomic) NSString *formattedRemainingOtherVolume;

@end
