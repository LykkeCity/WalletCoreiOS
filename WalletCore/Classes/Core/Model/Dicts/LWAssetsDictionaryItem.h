//
//  LWAssetsDictionaryItem.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 23.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWAssetsDictionaryItem : LWJSONObject {
    
}


#pragma mark - Properties

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSNumber *accuracy;
@property (readonly, nonatomic) NSString *issuerId;


#pragma mark - Root

+ (NSInteger)assetAccuracyById:(NSString *)identity;

@end
