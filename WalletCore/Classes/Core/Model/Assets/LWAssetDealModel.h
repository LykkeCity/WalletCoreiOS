//
//  LWAssetDealModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWAssetDealModel : LWJSONObject<NSCopying> {
    
}


#pragma mark - Properties

@property (copy,   nonatomic) NSString *identity;
@property (copy,   nonatomic) NSDate   *dateTime;
@property (copy,   nonatomic) NSString *orderType;
@property (copy,   nonatomic) NSNumber *volume;
@property (copy,   nonatomic) NSNumber *price;
@property (copy,   nonatomic) NSString *baseAsset;
@property (copy,   nonatomic) NSString *assetPair;
@property (copy,   nonatomic) NSString *blockchainId;
@property (assign, nonatomic) BOOL      blockchainSettled;
@property (copy,   nonatomic) NSNumber *totalCost;
@property (copy,   nonatomic) NSNumber *commission;
@property (copy,   nonatomic) NSNumber *position;
@property (copy,   nonatomic) NSNumber *accuracy;

@end
