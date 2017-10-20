//
//  LWPacketCurrencyDeposit.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketCurrencyDeposit.h"

@implementation LWPacketCurrencyDeposit
#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    
}


- (NSString *)urlRelative {
    return @"BankTransferRequest";
}

-(NSDictionary *) params
{
    return @{@"AssetId":self.assetId, @"BalanceChange":self.balanceChange};
}


@end
