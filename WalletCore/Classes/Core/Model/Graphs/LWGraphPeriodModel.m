//
//  LWGraphPeriodModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWGraphPeriodModel.h"

@implementation LWGraphPeriodModel

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    
    self.name=json[@"Name"];
    self.value=json[@"Value"];
    
    
    return self;
}
@end
