//
//  LWTransactionCashInOutModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWTransactionCashInOutModel : LWJSONObject {
    
}

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSNumber *amount;
@property (readonly, nonatomic) NSDate   *dateTime;
@property (readonly, nonatomic) NSString *asset;
@property (readonly, nonatomic) NSString *assetId;
@property (readonly, nonatomic) NSString *iconId;
@property (readonly, nonatomic) NSString *blockchainHash;
@property BOOL isRefund;
@property BOOL isSettled;
@property BOOL isOffchain;

@property (readonly, nonatomic) NSString *addressFrom;
@property (readonly, nonatomic) NSString *addressTo;

@property BOOL isForwardSettlement;


@end
