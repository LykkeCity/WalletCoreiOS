//
//  LWPacketCashOut.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketCashOut.h"
#import "LWPrivateKeyManager.h"


@implementation LWPacketCashOut



#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
}

- (NSString *)urlRelative {
    return @"CashOut";
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

    NSDictionary *dict=@{@"MultiSig" : self.multiSig,
                         @"Amount"   : self.amount,
                         @"AssetId"  : self.assetId,
//                         @"PrivateKey": [LWPrivateKeyManager shared].wifPrivateKeyLykke   //Transactions are signed locally
                         };
    
    return dict;
}

@end
