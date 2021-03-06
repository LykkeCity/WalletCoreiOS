//
//  LWPacketEmailHint.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketEmailHint.h"
#import "WalletCoreConfig.h"

@implementation LWPacketEmailHint


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }

}


- (NSString *)urlRelative {
    return @"RemindPasswordEmail";
}

-(NSDictionary *) params
{
    return @{
             @"PartnerId": WalletCoreConfig.partnerId,
             @"Email":self.email             
             };
}


@end
