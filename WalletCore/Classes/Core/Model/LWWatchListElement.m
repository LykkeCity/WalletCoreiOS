//
//  LWWatchListElement.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWWatchListElement.h"
#import "LWCache.h"

@interface LWWatchListElement()
{
    LWMarginalWalletAsset *marginalAsset;
    LWAssetPairModel *spotAssetPair;
}

@end

@implementation LWWatchListElement


-(id) initWithMarginalAsset:(LWMarginalWalletAsset *)asset
{
    self=[super init];
    marginalAsset=asset;
    
    return self;
    
}

-(id) initWithSpotAssetPair:(LWAssetPairModel *)asset
{
    self=[super init];
    spotAssetPair=asset;
    
    return self;
}

-(NSString *) name {
    if(marginalAsset) {
        return marginalAsset.name;
    }
    else {
        return [[LWCache displayIdForAssetId:spotAssetPair.baseAssetId] stringByAppendingFormat:@"/%@", [LWCache displayIdForAssetId: spotAssetPair.quotingAssetId]];
    }
}

-(NSString *) assetId {
    if(marginalAsset) {
        return marginalAsset.identity;
    }
    else {
        return spotAssetPair.identity;
    }
}

-(double) ask {
    if(marginalAsset) {
        return marginalAsset.rate.ask;
    }
    else {
        return [spotAssetPair.rate.ask doubleValue];
    }

}

-(double) bid {
    if(marginalAsset) {
        return marginalAsset.rate.bid;
    }
    else {
        return [spotAssetPair.rate.bid doubleValue];
    }
}

-(double) leverage {
    if(marginalAsset) {
        return marginalAsset.leverage;
    }
    else {
        return 0;
    }

}


-(id) asset {
    if(marginalAsset) {
        return marginalAsset;
    }
    else if(spotAssetPair) {
        return spotAssetPair;
    }
    
    return nil;
}



@end
