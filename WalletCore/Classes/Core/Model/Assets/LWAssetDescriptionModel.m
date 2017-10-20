//
//  LWAssetDescriptionModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetDescriptionModel.h"


@implementation LWAssetDescriptionModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity             = [json objectForKey:@"Id"];
        _assetClass           = [json objectForKey:@"AssetClass"];
        _popIndex             = [json objectForKey:@"PopIndex"];
        _details              = [json objectForKey:@"Description"];
        _issuerName           = [json objectForKey:@"IssuerName"];
        _numberOfCoins        = [json objectForKey:@"NumberOfCoins"];
        _marketCapitalization = [json objectForKey:@"MarketCapitalization"];
        _assetDescriptionURL  = [json objectForKey:@"AssetDescriptionUrl"];
        _fullName=[json objectForKey:@"FullName"];
        
        if(_popIndex && _popIndex.doubleValue == 0) {
            _popIndex = nil;
        }
    }
    return self;
}

@end
