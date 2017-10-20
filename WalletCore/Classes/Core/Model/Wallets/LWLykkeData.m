//
//  LWLykkeData.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWLykkeData.h"
#import "LWSpotWallet.h"


@implementation LWLykkeData {
    
}


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
//        _equity   = [json objectForKey:@"Equity"];

        NSMutableArray *list = [NSMutableArray new];
        for (NSDictionary *item in json[@"Assets"]) {
            [list addObject:[[LWSpotWallet alloc] initWithJSON:item]];
        }
        _wallets = list;
    }
    return self;
}

@end
