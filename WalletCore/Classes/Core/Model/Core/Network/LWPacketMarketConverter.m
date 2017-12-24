//
//  LWPacketMarketConverter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketMarketConverter.h"
#import "LWAssetMarketConvertedModel.h"

@implementation LWPacketMarketConverter

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"GOT MARKET CONVERTER %@", response);
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    for(NSDictionary *d in result[@"Converted"])
    {
        LWAssetMarketConvertedModel *m=[[LWAssetMarketConvertedModel alloc] initWithDict:d];
        if(m.assetId && m.price.doubleValue>0)
            [arr addObject:m];
    }
    _converted=arr;

}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params
{
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for(NSString *assetId in _assetsDict.allKeys)
    {
        [arr addObject:@{@"AssetId":assetId, @"Amount":_assetsDict[assetId]}];
    }
    
    return @{@"BaseAssetId":_lkkAssetId, @"AssetsFrom":arr, @"OrderAction":@"sell"};
}

- (NSString *)urlRelative {
    return @"market/converter/tobase";
}



@end
