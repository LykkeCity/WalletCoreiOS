//
//  LWPacketBuySellAsset.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBuySellAsset.h"
#import "LWAssetDealModel.h"
#import "LWPrivateKeyManager.h"



@implementation LWPacketBuySellAsset


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _deal = [[LWAssetDealModel alloc] initWithJSON:result[@"Order"]];
}

- (NSString *)urlRelative {
    return @"PurchaseAsset";
}

- (NSDictionary *)params {
    
    if(![LWPrivateKeyManager shared].wifPrivateKeyLykke)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Something happened! Your private key is not found in the keychain. Operation impossible." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        });
        return nil;
    }
    
    NSDictionary *params=@{@"BaseAsset" : self.baseAsset,
                           @"AssetPair" : self.assetPair,
                           @"Volume"    : self.volume,
                           @"Rate"      : self.rate,
//                           @"PrivateKey": [LWPrivateKeyManager shared].wifPrivateKeyLykke  //Transactions are signed via push
                           };
    
    NSLog(@"%@", params);
    
    return params;
}

@end
