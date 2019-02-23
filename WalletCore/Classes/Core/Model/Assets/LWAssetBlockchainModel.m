//
//  LWAssetBlockchainModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetBlockchainModel.h"


@implementation LWAssetBlockchainModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity      = [json objectForKey:@"Hash"];
        _date          = [json objectForKey:@"Date"];
        _confirmations = [json objectForKey:@"Confirmations"];
        _block         = [json objectForKey:@"Block"];
        _height        = [json objectForKey:@"Height"];
        _senderId      = [json objectForKey:@"SenderId"];
        _assetId       = [json objectForKey:@"AssetId"];
        _quantity      = [json objectForKey:@"Quantity"];
        _url           = [json objectForKey:@"Url"];
    }
    return self;
}

@end
