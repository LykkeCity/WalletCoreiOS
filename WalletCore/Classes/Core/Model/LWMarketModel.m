//
//  LWMarketModel.m
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWMarketModel.h"

@implementation LWMarketModel

#pragma mark - LWJSONObject
    
- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _assetPair = [json objectForKey:@"assetPair"];
        _volume24H = [json objectForKey:@"volume24H"];
        _lastPrice = [json objectForKey:@"lastPrice"];
        _bid = [json objectForKey:@"bid"];
        _ask = [json objectForKey:@"ask"];
    }
    return self;
}
    
@end
