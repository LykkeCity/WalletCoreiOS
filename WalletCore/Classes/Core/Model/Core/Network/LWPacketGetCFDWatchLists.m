//
//  LWPacketGetCFDWatchLists.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/02/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketGetCFDWatchLists.h"
#import "LWMarginalWalletsDataManager.h"
#import "LWMarginalAccount.h"
#import "LWWatchList.h"
#import "LWCache.h"

@implementation LWPacketGetCFDWatchLists

- (void)parseResponse:(id)response error:(NSError *)error {
    if([response isKindOfClass:[NSDictionary class]]) { //temporary - wrong api
        [super parseResponse:response error:error];
    }
    else {
        result = response;
    }
    NSLog(@"%@", response);
    
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
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
            LWWatchList *w = [[LWWatchList alloc] initWithDict:d type:CFD];
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
        [arr[0] setIsSelected:YES];
    }
    
    [LWCache instance].marginalWatchLists = arr;
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

-(NSString *) urlBase {
    
//    NSString *sss = [LWCache instance].marginalApiUrl;  //https://lykke-api-dev.azurewebsites.net/api/MarginTrading/  dev
    
    return [LWCache instance].marginalApiUrl;
}


- (NSString *)urlRelative {
    return @"watchlists"; //Watch lists are now the same for all margin accounts. I filter available assets in LWWatchList elements according to current account.
    
    
    NSString *accId = nil;
    for(LWMarginalAccount *acc in [LWMarginalWalletsDataManager shared].accounts) {
        if(acc.isCurrent) {
            accId = acc.identity;
        }
    }
    if(!accId) {
        return nil;
    }
    
//    return [@"MarginTrading/watchlists/" stringByAppendingString:accId];

    return [@"watchlists/" stringByAppendingString:accId];
}


@end
