//
//  LWMarketModel.h
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"

@interface LWMarketModel : LWJSONObject
@property (strong, nonatomic) NSString* assetPair;
@property (strong, nonatomic) NSNumber* volume24H;
@property (strong, nonatomic) NSNumber* lastPrice;
@property (strong, nonatomic) NSNumber* bid;
@property (strong, nonatomic) NSNumber* ask;
@end
