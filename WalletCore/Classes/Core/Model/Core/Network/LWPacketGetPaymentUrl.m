//
//  LWPacketGetPaymentUrl.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetPaymentUrl.h"
#import "LWCache.h"

@implementation LWPacketGetPaymentUrl

- (void)parseResponse:(id)response error:(NSError *)error {
    
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _urlString=result[@"Url"];
    _successUrl=result[@"OkUrl"];
    _failUrl=result[@"FailUrl"];
    _reloadRegex=result[@"ReloadRegex"];
    [LWCache instance].cashInVisaURL=_urlString;
    [LWCache instance].cashInVisaSuccessURL=_successUrl;
    [LWCache instance].cashInVisaFailURL=_failUrl;
    [LWCache instance].UrlsToFormatRegex=result[@"UrlsToFormatRegex"];
    
    
}


- (NSString *)urlRelative {
    return @"BankCardPaymentUrl";
}

-(NSDictionary *) params
{
   
    return _parameters;
}


@end
