//
//  LWWatchListElement.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWMarginalWalletAsset.h"
#import "LWAssetPairModel.h"

@interface LWWatchListElement : NSObject

-(id) initWithMarginalAsset:(LWMarginalWalletAsset *) asset;
-(id) initWithSpotAssetPair:(LWAssetPairModel *) asset;

@property (readonly, nonatomic) NSString *name;
@property (readonly) double ask;
@property (readonly) double bid;
@property (readonly) double leverage;
@property (readonly, nonatomic) NSString *assetId;

-(id) asset;

@end
