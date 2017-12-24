//
//  LWPacketAllAssetPairsRates.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAllAssetPairsRates.h"
#import "LWAssetPairRateModel.h"
#import "LWCache.h"

@implementation LWPacketAllAssetPairsRates


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _rate = [[LWAssetPairRateModel alloc] initWithJSON:result[@"Rate"]];

    [LWCache instance].cachedAssetPairsRates[self.assetId]=_rate;
    
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"AllAssetPairRates?id=%@", self.assetId];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


//-(NSDictionary *) params
//{
//    NSDictionary *params=@{@"Email":self.recModel.email, @"SignedOwnershipMsg":self.recModel.signature2, @"SmsCode":self.recModel.smsCode, @"NewPin":self.recModel.pin, @"NewPassword":self.recModel.password, @"NewHint":self.recModel.hint, @"EncodedPrivateKey":[[LWPrivateKeyManager shared] encryptKey:[LWPrivateKeyManager shared].wifPrivateKeyLykke password:self.recModel.password]};
//    NSLog(@"%@", params);
//    return params;
//}

@end
