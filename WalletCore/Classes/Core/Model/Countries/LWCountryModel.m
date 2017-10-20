//
//  LWCountryModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCountryModel.h"


@implementation LWCountryModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity = [json objectForKey:@"Id"];
        _name     = [json objectForKey:@"Name"];
        _prefix   = [json objectForKey:@"Prefix"];
        _iso2=[json objectForKey:@"Iso2"];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWCountryModel* data = [[[self class] allocWithZone:zone] init];
    data.identity = [self.identity copy];
    data.name     = [self.name copy];
    data.prefix   = [self.prefix copy];
    data.iso2=self.iso2;
    
    return data;
}

@end
