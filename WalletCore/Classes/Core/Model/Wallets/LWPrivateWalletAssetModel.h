//
//  LWPrivateWalletAssetModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWPrivateWalletAssetModel : NSObject

-(id) initWithDict:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *assetId;
@property (strong, nonatomic) NSNumber *baseAssetAmount;
@property (strong, nonatomic) NSNumber *amount;
@property (readonly, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *baseAssetId;


@end
