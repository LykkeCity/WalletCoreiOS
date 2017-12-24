//
//  LWAssetMarketConvertedModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetMarketConvertedModel.h"

@implementation LWAssetMarketConvertedModel

-(id) initWithDict:(NSDictionary *) dict
{
    self=[super init];
    
    _price=dict[@"Price"];
    _baseAssetId=dict[@"To"][@"AssetId"];
    _assetId=dict[@"From"][@"AssetId"];
    _amount=dict[@"From"][@"Amount"];
    _amountInBase=dict[@"To"][@"Amount"];
    
    
    return self;
}

@end
