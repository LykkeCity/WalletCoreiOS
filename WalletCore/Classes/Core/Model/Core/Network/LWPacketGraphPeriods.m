//
//  LWPacketGraphPeriods.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGraphPeriods.h"
#import "LWGraphPeriodModel.h"

@implementation LWPacketGraphPeriods

#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for(NSDictionary *d in result[@"AvailablePeriods"])
    {
        LWGraphPeriodModel *period=[[LWGraphPeriodModel alloc] initWithJSON:d];
        [arr addObject:period];
    }
    self.periods=arr;
    
    LWGraphPeriodModel *last=[[LWGraphPeriodModel alloc] initWithJSON:result[@"LastSelectedPeriod"]];
    self.lastSelectedPeriod=last;
    
    
}

- (NSString *)urlRelative {
    return @"GraphPeriods";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}



@end
