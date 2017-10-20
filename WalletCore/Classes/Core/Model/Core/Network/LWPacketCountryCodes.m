//
//  LWPacketCountryCodes.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketCountryCodes.h"


@implementation LWPacketCountryCodes


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    // read assets
    
    NSString *current=result[@"Current"];

    NSMutableArray *countries = [NSMutableArray new];
    for (NSDictionary *item in result[@"CountriesList"]) {
        LWCountryModel *country=[[LWCountryModel alloc] initWithJSON:item];
        [countries addObject: country];
        if([country.identity isEqualToString:current])
            _ipLocatedCountry=country;
        
    }
    _countries=countries;
    
}

- (NSString *)urlRelative {
    return @"CountryPhoneCodes";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
