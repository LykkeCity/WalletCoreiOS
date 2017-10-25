//
//  LWTransactionManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


typedef NS_ENUM(NSInteger, OffchainTransactionType) {
    OffchainTransactionTypeCreateChannel,
    OffchainTransactionTypeTransfer,
    OffchainTransactionTypeCashIn
};

//typedef enum {OFFCHAIN_TRANSACTION_TYPE_CREATE_CHANNEL,  OFFCHAIN_TRANSACTION_TYPE_TRANSFER, OFFCHAIN_TRANSACTION_TYPE_CASHIN} OFFCHAIN_TRANSACTION_TYPE;

@class LWPrivateWalletModel;
@class BTCTransaction;

@interface LWTransactionManager : NSObject

+(BTCTransaction *) signMultiSigTransaction:(NSString *) transaction withKey:(NSString *) key;
+(NSString *) signTransactionRaw:(NSString *) rawString key:(NSString *) privateKey;


+(NSString *) signOffchainTransaction:(NSString *)_transaction withKey:(NSString *)privateKey type:(OffchainTransactionType) type;
-(void) endAction;

+(void) testSign:(NSString *) transaction;

@property (strong, nonatomic) void(^backgroudFetchCompletionHandler)(UIBackgroundFetchResult result);

-(void) checkForPendingActions;

+ (instancetype)shared;


@end
