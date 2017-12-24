//
//  LWPacketMyLykkeCashInEmail.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketMyLykkeCashInEmail.h"

@implementation LWPacketMyLykkeCashInEmail

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    

    
}

- (NSString *)urlRelative {
    return @"MyLykkeCashInEmail";
}

-(NSDictionary *) params
{
    return @{@"AssetId":_assetId, @"Amount":_amount, @"LkkAmount":_lkkAmount, @"Price":_price};
    
}


@end
