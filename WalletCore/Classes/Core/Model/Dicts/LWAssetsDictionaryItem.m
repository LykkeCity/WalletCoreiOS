//
//  LWAssetsDictionaryItem.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 23.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetsDictionaryItem.h"
#import "LWCache.h"


@implementation LWAssetsDictionaryItem


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity = [json objectForKey:@"Id"];
        _name     = [json objectForKey:@"Name"];
        _accuracy = [json objectForKey:@"Accuracy"];
        _issuerId = [json objectForKey:@"IssuerId"];
    }
    return self;
}


#pragma mark - Root

+ (NSInteger)assetAccuracyById:(NSString *)identity {
    NSArray *list = [LWCache instance].assetsDict;
    if (list && list.count > 0) {
        for (LWAssetsDictionaryItem *item in list) {
            if ([item.identity isEqualToString:identity]) {
                return item.accuracy.integerValue;
            }
        }
    }
    return 8; // default
}

@end
