//
//  LWPacketLastBaseAssets.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketLastBaseAssets.h"
#import "LWAssetModel.h"
#import "LWCache.h"

@implementation LWPacketLastBaseAssets

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *item in result[@"Assets"]) {
        [list addObject:[[LWAssetModel alloc] initWithJSON:item]];
    }
    
    _lastAssets=list;
    
}

- (NSString *)urlRelative {
    return @"LastBaseAssets?n=5";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


@end
