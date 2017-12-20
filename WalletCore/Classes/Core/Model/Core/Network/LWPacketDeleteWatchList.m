//
//  LWPacketDeleteCFDWatchList.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/02/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketDeleteWatchList.h"
#import "LWWatchList.h"
#import "LWMarginalWalletsDataManager.h"
#import "LWMarginalAccount.h"
#import "LWCache.h"

@implementation LWPacketDeleteWatchList


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeDELETE;
}


-(NSString *) urlBase {
    if(_watchList.type == LWWatchListTypeCFD) {
    return [LWCache instance].marginalApiUrl;
    }
    else {
        return [super urlBase];
    }
}

- (NSString *)urlRelative {
    
    //    NSString *accId = nil;
    //    for(LWMarginalAccount *acc in [LWMarginalWalletsDataManager shared].accounts) {
    //        if(acc.isCurrent) {
    //            accId = acc.identity;
    //        }
    //    }
    //    if(!accId) {
    //        return nil;
    //    }
    
    NSString *urlStr;
//    if(_watchList.type == CFD) {
//        urlStr = [NSString stringWithFormat:@"watchlists/%@/%@", [LWMarginalWalletsDataManager shared].currentAccount.identity, _watchList.identity]; //removed AccountId from api
//    }
//    else {
        urlStr = [NSString stringWithFormat:@"watchlists/%@", _watchList.identity];
//    }
    
    return urlStr;
}

@end
