//
//  LWPacketGetMarginTermsStatus.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketGetMarginTermsStatus.h"
#import "LWCache.h"

@implementation LWPacketGetMarginTermsStatus

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    [LWCache instance].marginTermsOfUseUrl = result[@"MarginTermsOfUseLink"];
    [LWCache instance].spotTermsOfUseUrl = result[@"SpotTermsOfUseLink"];
    [LWCache instance].marginRiskDescriptionUrl = result[@"MarginRiskDescriptionLink"];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


- (NSString *)urlRelative {
    
    return @"ClientTrading/termsOfUse";
}

@end
