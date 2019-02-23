//
//  LWLykkeAssetsData.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWSpotWallet.h"
#import "LWUtils.h"
#import "LWCache.h"


@implementation LWSpotWallet {
    
}


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity    = [json objectForKey:@"Id"];
        _balance     = [json objectForKey:@"Balance"];
        _assetPairId = [json objectForKey:@"AssetPairId"];
        _hideIfZero  = [[json objectForKey:@"HideIfZero"] boolValue];

        _categoryId = [json objectForKey:@"CategoryId"];
        
        if([json[@"AmountInBase"] isKindOfClass:[NSNumber class]])
            _amountInBase=json[@"AmountInBase"];
        else
            _amountInBase=@(0);

        
        for(LWAssetModel *asset in [LWCache instance].allAssets) {
            if([_identity isEqualToString:asset.identity]) {
                _asset = asset;
                break;
            }
        }
        
        double balance=[LWUtils fairVolume:_balance.doubleValue accuracy:self.accuracy.intValue roundToHigher:NO];
        
        if(balance > 0.0)
            _balance=[NSNumber numberWithDouble:balance];
        
        
//        _name        = [json objectForKey:@"Name"];
//        _symbol      = [json objectForKey:@"Symbol"];
//        _issuerId    = [json objectForKey:@"IssuerId"];
//        _accuracy=[json objectForKey:@"Accuracy"];
        
        

    }
    return self;
}

-(void) setCategoryId:(NSString *)categoryId {
    _categoryId = categoryId;
}

-(NSString *) name {
    return _asset.displayId;
}

-(NSString *) symbol {
    return _asset.displayId;
}

-(NSString *) issuerId {
    return _asset.issuerId;
}

-(NSNumber *) accuracy {
    return _asset.accuracy;
}

@end
