//
//  LWAssetMarketConvertedModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWAssetMarketConvertedModel : NSObject


-(id) initWithDict:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *baseAssetId;
@property (strong, nonatomic) NSString *assetId;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *amountInBase;

@end
