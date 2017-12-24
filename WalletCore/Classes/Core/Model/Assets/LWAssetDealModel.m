//
//  LWAssetDealModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetDealModel.h"
#import "NSString+Date.h"


@implementation LWAssetDealModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        NSString *date = [json objectForKey:@"DateTime"];
        _identity          = [json objectForKey:@"Id"];
        _dateTime          = [json objectForKey:@"DateTime"];
        _dateTime          = [date toDate];
        _orderType         = [json objectForKey:@"OrderType"];
        _volume            = [json objectForKey:@"Volume"];
        _price             = [json objectForKey:@"Price"];
        _baseAsset         = [json objectForKey:@"BaseAsset"];
        _assetPair         = [json objectForKey:@"AssetPair"];
        _blockchainId      = [json objectForKey:@"BlockchainId"];
        _blockchainSettled = [[json objectForKey:@"BlockchainSetteled"] boolValue];
        _totalCost         = [json objectForKey:@"TotalCost"];
        _commission        = [json objectForKey:@"Comission"];
        _position          = [json objectForKey:@"Position"];
        _accuracy          = [json objectForKey:@"Accuracy"];
        if(_position == nil) {
            if([_orderType isEqualToString:@"Buy"]) {
                _position = @(_totalCost.doubleValue);
            }
            else {
                _position = @(-_totalCost.doubleValue);
            }
        }
        if(_baseAsset == nil) {
            _baseAsset = [json objectForKey:@"Asset"];
        }
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWAssetDealModel* data = [[[self class] allocWithZone:zone] init];
    data.identity = [self.identity copy];
    data.dateTime = [self.dateTime copy];
    data.orderType = [self.orderType copy];
    data.volume = [self.volume copy];
    data.price = [self.price copy];
    data.baseAsset = [self.baseAsset copy];
    data.assetPair = [self.assetPair copy];
    data.blockchainId = [self.blockchainId copy];
    data.blockchainSettled = self.blockchainSettled;
    data.totalCost = [self.totalCost copy];
    data.commission = [self.commission copy];
    data.position = [self.position copy];
    data.accuracy = [self.accuracy copy];
    
    return data;
}

@end
