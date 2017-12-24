//
//  LWPacketCurrencyWithdraw.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketCurrencyWithdraw.h"
#import "LWPrivateKeyManager.h"

@implementation LWPacketCurrencyWithdraw
#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    
}


- (NSString *)urlRelative {
    return @"CashOutSwiftRequest";
}

-(NSDictionary *) params
{
    ////Transactions are signed locally
//    NSMutableDictionary *params=[@{@"AssetId":self.assetId, @"Bic":self.bic, @"AccNumber":self.accountNumber, @"AccName":self.accountName, @"Amount":self.amount, @"PrivateKey":[LWPrivateKeyManager shared].wifPrivateKeyLykke} mutableCopy];
    NSMutableDictionary *params=[@{@"AssetId":self.assetId, @"Bic":self.bic, @"AccNumber":self.accountNumber, @"AccName":self.accountName, @"Amount":self.amount, @"BankName":_bankName, @"AccHolderAddress":_holderAddress} mutableCopy];
    if(self.postCheck)
        params[@"Postcheck"]=self.postCheck;
    NSLog(@"%@", params);
    return params;
}
@end
