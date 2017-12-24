//
//  LWLykkeWalletsData.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWLykkeWalletsData.h"
#import "LWBankCardsData.h"
#import "LWCache.h"


@implementation LWLykkeWalletsData {
    
}


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _lykkeData = [[LWLykkeData alloc] initWithJSON:json[@"Lykke"]];
        
        NSMutableArray *list = [NSMutableArray new];
        for (NSDictionary *item in json[@"BankCards"]) {
            [list addObject:[[LWBankCardsData alloc] initWithJSON:item]];
        }
        _bankCards = list;
        
        _multiSig = [json objectForKey:@"MultiSig"];
        [LWCache instance].multiSig = [_multiSig copy];

        _coloredMultiSig = [json objectForKey:@"ColoredMultiSig"];
        [LWCache instance].coloredMultiSig = [_coloredMultiSig copy];
        
        [LWCache instance].solarCoinAddress=[json[@"SolarCoinAddress"] copy];
    }
    return self;
}

@end
