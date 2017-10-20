//
//  LWAssetDescriptionModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWAssetDescriptionModel : LWJSONObject {
    
}


#pragma mark - Properties

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *assetClass;
@property (readonly, nonatomic) NSNumber *popIndex;
@property (readonly, nonatomic) NSString *details;
@property (readonly, nonatomic) NSString *issuerName;
@property (readonly, nonatomic) NSString *numberOfCoins;
@property (readonly, nonatomic) NSString *marketCapitalization;
@property (readonly, nonatomic) NSString *assetDescriptionURL;
@property (readonly, nonatomic) NSString *fullName;

@end
