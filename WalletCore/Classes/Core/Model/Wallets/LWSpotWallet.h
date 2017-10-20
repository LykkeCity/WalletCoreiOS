//
//  LWLykkeAssetsData.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"
#import "LWAssetModel.h"


@interface LWSpotWallet : LWJSONObject {
    
}

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *symbol;
@property (readonly, nonatomic) NSNumber *balance;
@property (readonly, nonatomic) NSString *assetPairId;
@property (readonly, nonatomic) NSString *issuerId;
@property (readonly)    BOOL      hideIfZero;
@property (readonly, nonatomic) NSNumber *accuracy;

@property (readonly, nonatomic) NSString *categoryId;

@property (readonly, nonatomic) NSNumber *amountInBase;

@property (readonly, nonatomic) LWAssetModel *asset;

@end
