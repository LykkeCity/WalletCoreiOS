//
//  LWPacketSetRevertedPair.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketSetRevertedPair.h"

@implementation LWPacketSetRevertedPair


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    
}


- (NSString *)urlRelative {
    return @"InvertedAssetPairs";
}

-(NSDictionary *) params
{
    
    NSDictionary *params=@{@"AssetPairId":self.assetPairId, @"Inverted":@(_inverted)};
    return params;
}


@end
