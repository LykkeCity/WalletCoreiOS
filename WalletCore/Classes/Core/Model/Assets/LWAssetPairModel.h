//
//  LWAssetPairModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"
#import "LWAssetPairRateModel.h"


@interface LWAssetPairModel : NSObject {
    
}

+(LWAssetPairModel *) assetPairWithDict:(NSDictionary *) dict;

#pragma mark - Properties

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *group;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSNumber *accuracy;
@property (readonly, nonatomic) NSString *baseAssetId;
@property (readonly, nonatomic) NSString *quotingAssetId;
@property (readonly, nonatomic) NSNumber *invertedAccuracy;
@property (readonly, nonatomic) NSNumber *normalAccuracy;


@property (readonly, nonatomic) NSString *originalBaseAsset;

@property BOOL inverted;
    
@property (readonly) NSString *baseAssetDisplayId;
@property (readonly) NSString *quotingAssetDisplayId;

@property (strong, nonatomic) LWAssetPairRateModel *rate;

@end
