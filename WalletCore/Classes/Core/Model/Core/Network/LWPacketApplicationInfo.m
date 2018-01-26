//
//  LWPacketAPIVersion.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketApplicationInfo.h"
#import "NSString+Date.h"
#import "LWCache.h"

@implementation LWPacketApplicationInfo


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.apiVersion=result[@"AppVersion"];
    self.termsOfUse=result[@"TermsOfUseLink"];
    if(result[@"CountryPhoneCodesLastModified"])
    {
        NSString *string=[result[@"CountryPhoneCodesLastModified"] stringByReplacingOccurrencesOfString:@"T" withString:@" "];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [dateFormatter setTimeZone:gmt];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateFromString=[dateFormatter dateFromString:string];

        [[NSUserDefaults standardUserDefaults] setObject:dateFromString forKey:@"CountryPhoneCodesLastModified"];
    }
    
    [LWCache instance].informationBrochureUrl=result[@"InformationBrochureLink"];
    [LWCache instance].termsOfUseUrl=result[@"TermsOfUseLink"];
    [LWCache instance].refundInfoUrl=result[@"RefundInfoLink"];
    [LWCache instance].supportPhoneNum=result[@"SupportPhoneNum"];
    [LWCache instance].userAgreementUrl=result[@"UserAgreementUrl"];
    [LWCache instance].wampServerUrl=result[@"MarginSettings"][@"WampHost"];
    [LWCache instance].marginalApiUrl=result[@"MarginSettings"][@"ApiUrl"];
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"ApplicationInfo";
}

@end
