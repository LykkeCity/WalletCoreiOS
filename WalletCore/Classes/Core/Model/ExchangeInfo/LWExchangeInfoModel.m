//
//  LWExchangeInfoModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeInfoModel.h"


@implementation LWExchangeInfoModel


#pragma mark - LWAssetDealModel

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWExchangeInfoModel* data = [super copyWithZone:zone];
    return data;
}

@end
