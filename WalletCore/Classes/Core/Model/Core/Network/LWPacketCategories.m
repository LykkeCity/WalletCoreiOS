//
//  LWPacketCategories.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketCategories.h"
#import "LWAssetCategoryModel.h"
#import "LWCache.h"

@implementation LWPacketCategories

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for(NSDictionary *d in result[@"AssetCategories"])
    {
        LWAssetCategoryModel *c=[[LWAssetCategoryModel alloc] initWithDictionary:d];
        [arr addObject:c];
    }
    
    
    
    _categories=arr;
    [LWCache instance].walletsCategories = _categories;
    
 }

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"assetcategories";
}


@end
