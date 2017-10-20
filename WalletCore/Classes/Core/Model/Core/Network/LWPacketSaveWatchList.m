//
//  LWPacketSaveWatchList.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/02/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketSaveWatchList.h"
#import "LWCache.h"

@implementation LWPacketSaveWatchList

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    if(_watchList.identity == nil) {
        _watchList.identity = result[@"Id"];
    }
    
}

- (GDXRESTPacketType)type {
    if(_watchList.type == CFD || _watchList.identity == nil)
        return GDXRESTPacketTypePOST;
    else
        return GDXRESTPacketTypePUT;
}

-(NSString *) urlBase {
    
    NSString *url = [super urlBase];
    if(_watchList.type == CFD) {
        return [LWCache instance].marginalApiUrl;
    }
    else {
        return [super urlBase];
    }
}



-(NSDictionary *) params {
    
    NSDictionary *dict = _watchList.dictionary;
    return dict;
}

- (NSString *)urlRelative {
    if(_watchList.identity == nil || _watchList.type == CFD)
        return @"watchlists";
    else {
        return [@"watchlists" stringByAppendingFormat:@"/%@",_watchList.identity];
    }
}




@end
