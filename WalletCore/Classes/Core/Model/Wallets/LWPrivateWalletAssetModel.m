//
//  LWPrivateWalletAssetModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletAssetModel.h"
#import "LWCache.h"

@implementation LWPrivateWalletAssetModel


-(id) initWithDict:(NSDictionary *) d
{
    self=[super init];
    self.assetId=d[@"AssetId"];
    self.amount=d[@"Balance"];
    _name=[LWCache displayIdForAssetId:self.assetId];
    self.baseAssetAmount=d[@"AmountInBase"];
    self.baseAssetId=d[@"BaseAssetId"];
    return self;
}

@end
