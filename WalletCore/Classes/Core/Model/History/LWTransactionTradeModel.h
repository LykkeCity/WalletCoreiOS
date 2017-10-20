//
//  LWTransactionTradeModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"



@interface LWTransactionTradeModel : LWJSONObject {
    
}


@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSDate   *dateTime;
@property (readonly, nonatomic) NSString *asset;
@property (readonly, nonatomic) NSString *assetId;
@property (readonly, nonatomic) NSNumber *volume;
@property (readonly, nonatomic) NSString *iconId;
@property (readonly, nonatomic) NSString *blockchainHash;
@property BOOL isSettled;
@property BOOL isOffchain;

@property (readonly, nonatomic) NSString *addressFrom;
@property (readonly, nonatomic) NSString *addressTo;

@end
