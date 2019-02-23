//
//  LWAppSettingsModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAppSettingsModel.h"
#import "LWAssetModel.h"
#import "LWCache.h"


@implementation LWAppSettingsModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _rateRefreshPeriod = [json objectForKey:@"RateRefreshPeriod"];
        _baseAsset         = [[LWAssetModel alloc] initWithJSON:json[@"BaseAsset"]];
        _shouldSignOrders  = [[json objectForKey:@"SignOrder"] boolValue];
        _depositUrl        = [json objectForKey:@"DepositUrl"];
        _debugMode         = [[json objectForKey:@"DebugMode"] boolValue];
        _refundAddress     = json[@"RefundSettings"][@"Address"];
        
        [LWCache instance].shouldSignOrder = _shouldSignOrders;
        [LWCache instance].depositUrl      = _depositUrl;
        [LWCache instance].debugMode       = _debugMode;
    }
    return self;
}

@end
