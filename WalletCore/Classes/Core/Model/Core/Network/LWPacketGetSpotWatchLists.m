//
//  LWPacketGetSpotWatchLists.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 04/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketGetSpotWatchLists.h"
#import "LWCache.h"
#import "LWWatchList.h"


@implementation LWPacketGetSpotWatchLists
- (void)parseResponse:(id)response error:(NSError *)error {
    if([response isKindOfClass:[NSDictionary class]]) { //temporary - wrong api
        [super parseResponse:response error:error];
    }
    else {
        result = response;
    }
    NSLog(@"%@", response);
    
    
//    NSMutableArray *arr = [[NSMutableArray alloc] init];
//    for(NSDictionary *d in result) {
//        LWWatchList *w = [[LWWatchList alloc] initWithDict:d type:SPOT];
//        [arr addObject:w];
//    }
//    
    
    
    
    NSMutableArray<LWWatchList *> *arr = [[NSMutableArray alloc] init];
    for(NSDictionary *d in result) {
        BOOL found = NO;
        for(LWWatchList *w in [LWCache instance].marginalWatchLists) {
            if(w.identity != nil && [w.identity isEqualToString:d[@"Id"]]) {
                found = YES;
                [w updateWithDict:d];
                [arr addObject:w];
            }
        }
        if(!found) {
            LWWatchList *w = [[LWWatchList alloc] initWithDict:d type:LWWatchListTypeSPOT];
            [arr addObject:w];
        }
    }

    BOOL foundSelected = NO;
    for(LWWatchList *w in arr) {
        if(w.isSelected) {
            foundSelected = YES;
            break;
        }
    }
    if(foundSelected == NO && arr.count > 0) {
        [arr[0] setSelected:YES];
    }

    
    [LWCache instance].spotWatchLists = arr;

    
}


- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}



- (NSString *)urlRelative {
    
    return @"WatchLists";
}

@end
