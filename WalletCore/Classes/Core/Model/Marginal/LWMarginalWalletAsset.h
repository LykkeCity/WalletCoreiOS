//
//  LWMarginalWalletAsset.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWMarginalWalletRate.h"

@class LWMarginalAccount;

@interface LWMarginalWalletAsset : NSObject

-(id) initWithDict:(NSDictionary *) dict;

-(void) updateWithDict:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *baseAssetId;
@property (strong, nonatomic) NSString *quotingAssetId;

@property double swapLong;
@property double swapShort;

@property (strong, nonatomic)  LWMarginalAccount *account;


@property int accuracy;

@property double leverage;
@property double leveragHigher;

@property (readonly) double deltaAsk;
@property (readonly) double deltaBid;

@property (strong, nonatomic) LWMarginalWalletRate *rate;
@property (strong, nonatomic) LWMarginalWalletRate *previousRate;

@property BOOL askRaising;
@property BOOL bidRaising;


@property (strong, nonatomic) NSString *baseAssetName;

@property (strong, nonatomic) NSMutableArray *changes;

@property (strong, nonatomic) NSArray *graphValues;

- (BOOL)ratesChanged:(NSArray *)newRates;

@end
