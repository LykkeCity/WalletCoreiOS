//
//  WalletCoreConfig.m
//  WalletCore
//
//  Created by Georgi Stanev on 2.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import "WalletCoreConfig.h"

@implementation WalletCoreConfig

static NSString *_partnerId;

+ (NSString *)partnerId {
    if (_partnerId == nil) {
        _partnerId = @"";
    }
    return _partnerId;
}

+ (void)setPartnerId:(NSString *)newPartner {
    if (_partnerId != newPartner) {
        _partnerId = newPartner;
    }
}

+ (void)configure:(NSString*) partnerId {
    WalletCoreConfig.partnerId = partnerId;
}

@end
